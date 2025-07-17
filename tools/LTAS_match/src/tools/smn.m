function noise = smn(speech,fsHz,strFB,post)
%smn   Create speech-modulated noise.
% 
%USAGE
%   noise = smn(speech,fsHz)
%   noise = smn(speech,fsHz,strFB,post)
%
%INPUT ARGUMENTS
%   speech : speech signal [nSamples x 1]
%     fsHz : sampling frequency in Hz
%    strFB : string defining the freuqency decomposition 
%            'broadband'       
%            '2channel_cheby'  crossover at 1000 Hz
%            '3channel_cheby'  crossover at 850 and 2500 Hz
%            '2channel_butter' crossover at 1000 Hz
%            '3channel_butter' crossover at 850 and 2500 Hz (default)
%            '8channel_butter' (noise will be intelligible)
%                
%     post : post processing method which recues the scratchy character of
%            the noise (default, post = 1)
%            0 = no post processing
%            1 = use random phase values
%            2 = shuffle phase values
%                
%OUTPUT ARGUMENTS
%   noise : speech-modulated noise [nSamples x 1]
% 
%REFERENCES
%   [1] Dreschler, W. A., Verschuure, H., Ludvigsen, C. and Westermann, S.
%       (2001). "ICRA Noises: Artificial noise signals with speech-like
%       spectral and temporal properties for hearing instrument
%       assessment," International Journal of Audiology, 40(3), 148-157.  
% 
%   See also ltasTemplate and ltasEqualize.

%   Developed with Matlab 8.3.0.532 (R2014a). Please send bug reports to:
%   
%   Author  :  Tobias May, (c) 2015
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2015/04/10
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS
% 
% 
% Check for proper input arguments
if nargin < 2 || nargin > 4
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 3 || isempty(strFB); strFB = '3channel_butter'; end
if nargin < 4 || isempty(post);  post  = 1;                 end

% Determine size of input signal
dim = size(speech);

% Check for proper size
if min(dim > 1)
    error('Monaural input is required!')
end


%% CONFIGURE SUBBAND PROCESSING
% 
% 
% Decompose input
switch lower(strFB)
    case 'broadband'
        [bFB{1}, aFB{1}] = deal(1);
        cutoffHz = [];
        
    case '2channel_cheby'
        % Cut-off frequency in Hertz
        cutoffHz = 1000;
        
        % Maximum pass-band ripples in dB
        ripple  = 1;    
        orderFB = 6; 
        
        % Implement two-channel filterbank
        [bFB{1}, aFB{1}] = cheby1(orderFB,ripple,cutoffHz/(fsHz/2),'low');
        [bFB{2}, aFB{2}] = cheby1(orderFB,ripple,cutoffHz/(fsHz/2),'high');
        
    case '3channel_cheby'
        % Cut-off frequencies in Hertz
        cutoffHz(1) = 850;  % Lowest band covers 1st formant 
        cutoffHz(2) = 2500; % Middle band covers 2nd formant 
                            % Highest band covers unvoiced fricatives
                            
        % Normalized cut-off frequencies
        wn = cutoffHz/(fsHz/2);
                          
        % Maximum pass-band ripples in dB
        ripple  = 1;      
        orderFB = 8;
        
        % Implement three-channel filterbank
        [bFB{1}, aFB{1}] = cheby1(orderFB,ripple,wn(1),'low');
        [bFB{2}, aFB{2}] = cheby1(orderFB,ripple,wn,'bandpass');
        [bFB{3}, aFB{3}] = cheby1(orderFB,ripple,wn(2),'high');
    
    case '2channel_butter'
        % Cut-off frequency in Hertz
        cutoffHz = 1000;
        orderFB  = 8; 
        
        % Implement two-channel filterbank
        [bFB{1}, aFB{1}] = butter(orderFB,cutoffHz/(fsHz/2),'low');
        [bFB{2}, aFB{2}] = butter(orderFB,cutoffHz/(fsHz/2),'high');        
        
    case '3channel_butter'
        % Cut-off frequencies in Hertz
        cutoffHz(1) = 850;  % Lowest band covers 1st formant 
        cutoffHz(2) = 2500; % Middle band covers 2nd formant 
        
        % Normalized cut-off frequencies
        wn = cutoffHz/(fsHz/2);
        
        % Filter slope in dB
        slopedB = 100;
                
        % Calculate required filter order
        orderFB = 2 * round(slopedB/20/2);
        
        % Implement three-channel filterbank
        [bFB{1}, aFB{1}] = butter(orderFB,wn(1),'low');
        [bFB{2}, aFB{2}] = butter(orderFB,wn,'bandpass');
        [bFB{3}, aFB{3}] = butter(orderFB,wn(2),'high');
        
   case '8channel_butter'
        % Cut-off frequencies in Hertz
        cutoffHz = createFreqAxisLOG(128,fsHz/4,7);  
                        
        % Normalized cut-off frequencies
        wn = cutoffHz/(fsHz/2);
        
        % Filter slope in dB
        slopedB = 100;
        
        % Calculate required filter order
        orderFB = 2 * round(slopedB/20/2);
        
        % Ensure all filters have the same order
        orderBP = orderFB / 2;
        
        % Number of filters
        nFilters = numel(cutoffHz) + 1;
        
        % Allocate memory for filter coefficients
        [bFB,aFB] = deal(cell(nFilters,1));
        
        % Implement filterbank
        for ii = 1 : nFilters
           if ii == 1
               [bFB{1}, aFB{1}] = butter(orderFB,wn(1),'low');
           elseif ii > 1 && ii <= numel(cutoffHz)
               [bFB{ii}, aFB{ii}] = butter(orderBP,wn(ii-1:ii),'bandpass');
           else
               [bFB{ii}, aFB{ii}] = butter(orderFB,wn(ii-1),'high');
           end
        end
    otherwise
        error('Frequency decomposition "%s" is not supported.',lower(strFB))
end

% Frequency range
fcHz = [0 cutoffHz fsHz/2];

if 0
    % Derive transfer functions of filters
    for ii = 1 : numel(bFB)
        [h(:,ii),fHz] = freqz(bFB{ii},aFB{ii},fsHz,fsHz);
    end
    
    figure;
    semilogx(fHz,20*log10(abs(h)))
    xlim([10 fsHz/2])
    ylim([-80 5])
end


%% SPLIT SPEECH INTO SUBBAND SIGNALS AND PERFORM SCHROEDER PROCESSING
% 
% 
% Determine number of bands
nBands = numel(bFB);

% Number of samples
nSamples = size(speech,1);

% Allocate memory
bands = zeros(nSamples,nBands);

% Loop over the number of bands
for ii = 1 : nBands
    
    % Filter speech signal into bands
    bands(:,ii) = filter(bFB{ii},aFB{ii},speech);

    % Render speech unintelligble using Schroeder processing, which will
    % preserve the modulation properties. The output signal has a white
    % spectrum.
    bands(:,ii) = schroeder(bands(:,ii));

    % Filter signals again to obtain a band-limited subband signal. Here,
    % the time-reversed signal is filtered and reversed again to remove any
    % phase distortions introduced by the filtering. 
    bands(:,ii) = flipud(filter(bFB{ii},aFB{ii},flipud(bands(:,ii))));
    
    % Normalize subband by its RMS
    bands(:,ii) = bands(:,ii) / rms(bands(:,ii));
    
    % Scale subband according to its bandwidth to ensure that the sum
    % across all subbands produces a signal with a white spectrum.
    bands(:,ii) = bands(:,ii) * sqrt(fcHz(ii + 1) - fcHz(ii));
end

% Combine signals across bands (noiseRaw has a white spectrum)
noiseRaw = sum(bands,2);


%% POST-PROCESSING
% 
% 
% Randomize phase to reduce the "unpleasant scratchy sound" [1]
switch post
    case {0 false}
        noise = noiseRaw;
    case {1 true}
        noise = randPhase(noiseRaw,fsHz,20E-3,0.875,false);
    case 2
        noise = randPhase(noiseRaw,fsHz,20E-3,0.875,true);
    otherwise
        error('Post processing method "%i" is not supported.',post)
end

   
