function [mSpec,cfModHz] = modSpec(input,fsHz,cfModHz,bNorm)
%modSpec   Compute the long-term modulation spectrum. 
%   The envelope of the input signal is extracted by half-wave
%   rectification and low-pass filtering and subsequently analyzed by a
%   bank of modulation filters. The RMS measured across each modulation
%   filter is normalized by the DC component of the envelope [1].  
% 
%USAGE
%   [mSpec,cfModHz] = modSpec(input,fsHz)
%   [mSpec,cfModHz] = modSpec(input,fsHz,cfModHz,bNorm)
%
%INPUT ARGUMENTS
%     input : input signal [nSamples x nSubbands]
%      fsHz : sampling frequency in Hz
%   cfModHz : modulation filter center frequencies in Hertz
%             (default, cfModHz = [0.5 1 2 4 8 16 32])
%     bNorm : binary flag indicating if the modulation spectrum should be
%             normalized by the DC component of the envelope 
%             (default, bNorm = true)
% 
%OUTPUT ARGUMENTS
%   mSpec : modulation spectrum [nSubbands x nFilters]
%    cfHz : modulation filter center frequencies [nFilters x 1]
% 
%   modSpec(...) plots the modulation spectrum in a new figure.
% 
%   See also ltas.
% 
%EXAMPLE
%   % Load signal (y & Fs)
%   load('chirp.mat');
% 
%   % Compute and plot the modulation spectrum
%   modSpec(y,Fs);
% 
%REFERENCES
%   [1] Dreschler, W. A., Verschuure, H., Ludvigsen, C. and Westermann, S.
%       (2001). "ICRA Noises: Artificial noise signals with speech-like
%       spectral and temporal properties for hearing instrument
%       assessment," International Journal of Audiology, 40(3), 148-157.  

%   Developed with Matlab 8.3.0.532 (R2014a). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2015
%              Technical University of Denmark (DTU)
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2015/02/09
%   v.0.2   2015/02/20 added subband processing
%   v.0.3   2015/04/02 added FFT-based MTF calculation
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
if nargin < 3 || isempty(cfModHz); cfModHz = [0.5 1 2 4 8 16 32]; end
if nargin < 4 || isempty(bNorm);   bNorm   = true;                end


%% EXTRACT ENVELOPE
% 
%
% Half-wave rectification
env = max(input,0);

% Determine low-pass cut-off frequency
cfHzLP = max(100,2 * round(max(cfModHz)));

% Low-pass filtering
if cfHzLP < fsHz/2
    [bLP,aLP] = butter(2,cfHzLP/(fsHz*0.5));
    env = filter(bLP,aLP,env);
end


%% DOWN-SAMPLE ENVELOPE
% 
% 
% Reference sampling frequency of the envelope signal after resampling
% (default => 1200 Hz). If higher modulation frequencies are requested,
% this reference will be changed accordingly.
fsHzEnv = max(1200,min(fsHz,4 * round(max(cfModHz))));

% Resample envelope
env = resample(env,fsHzEnv,fsHz);


%% PERFORM MODULATION SPECTRUM ANALYSIS
% 
% 
% Check input size
[nSamples,nSubbands] = size(input); %#ok

% Number of modulation filters
nFilters = numel(cfModHz);

% Allocate memory
mspecMod = zeros(nSubbands,nFilters);
mspecDC  = zeros(nSubbands,1);

% Determine FFT resolution
nfft = pow2(nextpow2(size(env,1)));

% Frequency vector from 0 to fsHz
freqHz = (0:(nfft/2))'/(nfft/2)/2 * fsHzEnv;

% Find lower and upper 3dB edge freqencies
fModLowHz  = cfModHz .* 2^(-1 / 2);
fModHighHz = cfModHz .* 2^( 1 / 2);

% Bandwidth in Hertz
bwHz = fModHighHz - fModLowHz;

% Q-factor
qFactor = cfModHz ./ bwHz; %#ok

% Loop over the number of subbands
for ii = 1 : nSubbands
    
    % Subband envelope
    subband = env(:,ii);
    
    % Magnitude spectrum
    mspec = abs(fft(subband,nfft)) / nfft;
    mspec = mspec(1:(1+fix(nfft/2)));
    
    % Take positive frequencies times two
    % (to reflect energy of negative frequencies)
    if rem(nfft,2)
        % Single-sided spectrum is odd, only DC is unique
        mspec(2:end,:) = mspec(2:end,:) * 2;
    else
        % Single-sided spectrum is even, do not double DC or Nyquist
        mspec(2:end-1,:) = mspec(2:end-1,:) * 2;
    end
    
    % Loop over number of modulation filters
    for mm = 1 : nFilters
        
        % Find frequency indices for mm-th modulation filter
        idxMod = fModLowHz(mm) < freqHz & freqHz < fModHighHz(mm);
        
        % Check if modulation filter is represented
        if sum(idxMod) == 0
            error(['No FFT bins detected for modulation filter '  ,...
                'centered at ',num2str(cfModHz(mm)),' Hz. Either ',...
                'increase the center frequency of lowest modulation ',...
                'filter or increase the signal duration.'])
        end
        
        % Measure the RMS within each modulation filter
%         pspecMod(ii,mm) = sqrt(sum(pspec(idxMod).^2,1)) / sqrt(bwHz(ii));
        mspecMod(ii,mm) = sqrt(sum(mspec(idxMod).^2,1));
    end
    
    % DC component of the envelope signal
    mspecDC(ii) = mspec(1);
end

% Normalize modulation RMS by DC component
if bNorm
    mSpec = bsxfun(@rdivide,mspecMod,mspecDC);
else
    mSpec = mspecMod;
end


%% SHOW RESULT
% 
% 
% If no output is specified
if nargout == 0
    if nSubbands == 1
        figure;
        plot(mSpec,'.-','markersize',20);
        grid on;
        set(gca,'xtick',1:numel(cfModHz),'xticklabel',...
            num2str(cfModHz','%1.1f'))
        xlabel('Modulation frequency (Hz)')
        ylabel('Modulation spectrum')
    else
        figure;
        contourf(mSpec);
        axis xy
        colorbar;
        set(gca,'xtick',1:nFilters,'xticklabel',...
            num2str(cfModHz','%1.1f'))
        xlabel('Modulation frequency (Hz)')
        ylabel('Number of subbands')
    end
end

