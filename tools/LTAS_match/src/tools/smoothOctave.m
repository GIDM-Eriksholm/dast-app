function out = smoothOctave(input,fHz,nOct)
%smoothOctave   Perform 1/N octave smoothing across frequency.
%   The smoothing is performed across the first dimension.
% 
%USAGE
%   out = smoothOctave(input,fHz)
%   out = smoothOctave(input,fHz,nOct)
%
%INPUT ARGUMENTS
%   input : input matrix (e.g. STFT magnitudes) [nDFTBins x nFrames]
%     fHz : frequency vector in Hertz [nDFTBins x 1]
%    nOct : number of filters per octave (default, nBandsPerOct = 3)
% 
%OUTPUT ARGUMENTS
%   out : smoothed output matrix [nDFTBins x nFrames]
% 
%   smoothOctave(...) visualizes the smoothing in a new figure.   
% 
%   See also ltas.
% 
%ACKNOWLEDGEMENT
%   This function is based on "smoothSpectrum", a MATLAB function that is
%   part of the IoSR Toolbox (https://github.com/IoSR-Surrey/MatlabToolbox)
% 
%EXAMPLE
%   % STFT representation of white Gaussian noise 
%   [X,tSec,fHz] = stft(randn(10E3,1),16E3);
% 
%   % Perform 1/3 octave smoothing
%   smoothOctave(20*log10(mean(abs(X),2)),fHz,3);

%   Developed with Matlab 9.1.0.441655 (R2016b). Please send bug reports to
%   
%   Author  :  Tobias May, © 2016
%              Technical University of Denmark (DTU)
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2016/11/16
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS  
% 
% 
% Check for proper input arguments
if nargin < 2 || nargin > 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 3 || isempty(nOct); nOct = 3; end

% Determine dimensionality
[nDFTBins,dim] = size(input);

% Check dimension of input matrix
if numel(dim) > 1
    error('"Input" must be either one or two-dimensional.')
end

% Check dimension of frequency vector
if numel(fHz) ~= nDFTBins
    error('The length of "fHz" must match the second input dimension.')
end


%% PERFORM OCTAVE SMOOTHING
% 
% 
% Copy input
out = input;

% Ensure fHz is a row vector
fHz = fHz(:)';

% Only process non-zero frequency bins
idxAboveZero = find(fHz > 0);

% Loop over nin-zero frequency bins
for ii = idxAboveZero(:)'
    
    % Create normalized Gaussian kernel
    sigma  = (fHz(ii)/nOct) / pi;
    kernel = exp(-(((fHz(idxAboveZero)-fHz(ii)).^2)./(2.*(sigma^2)))); 
    kernel = kernel / sum(kernel);
    
    % Check if kernel is positive
    if any(sum(kernel < 0))
        warning('Negative kernel elements detected.')
    end
    
    % Apply kernel
    out(ii,:) = kernel * out(idxAboveZero,:);
end


%% SHOW RESULTS
% 
% 
% If no output is specified
if nargout == 0
    
    figure;
    if dim > 1
        subplot(211)
        imagesc(input);
        xlabel('Number of frames')
        ylabel('Number of DFT bins')
        title('Input')
        axis xy
        
        subplot(212)
        imagesc(out);
        xlabel('Number of frames')
        ylabel('Number of DFT bins')
        title(['1/',num2str(nOct),' octave smoothing'])
        axis xy
    else
        semilogx(fHz,input,fHz,out);
        xlim([fHz(1) fHz(end)])
        grid on;
        legend({'Input' 'Output'})
        xlabel('Frequency (Hz)')
        ylabel('Amplitude')
        title(['1/',num2str(nOct),' octave smoothing'])
    end
end
