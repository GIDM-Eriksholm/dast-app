function out = randPhase(input,fsHz,winSec,overlap,bShuffle)
%randPhase   Randomize phase in the FFT domain.
%   An overlap-add framework is used to segment the input into overlapping
%   frames. After applying an FFT, the phase of individual time frames is
%   randomized and the input signal is reconstructed. The amount of
%   smoothing can be controlled by the overlap factor of adjacent frames.
%   An overlap of 87.5% has been suggested in [1].    
% 
%USAGE
%   out = randPhase(input,fsHz)
%   out = randPhase(input,fsHz,winSec,overlap,bShuffle)
%
%INPUT ARGUMENTS
%      input : input signal [nSamples x 1]
%       fsHz : sampling frequency in Hz
%     winSec : block size in seconds (default, winSec = 20E-3)
%    overlap : overlap factor of adjacent frames within the range [0 1) 
%              (default, overlap = 0.875) 
%   bShuffle : if true, the original phase values will be shuffled across
%              FFT bins for each frame; if false, the original phase will
%              be replaced by random values (default, bShuffle = false) 
% 
%OUTPUT ARGUMENTS
%   out : output signal [nSamples x 1]
% 
%REFERENCES
%   [1] Dreschler, W. A., Verschuure, H., Ludvigsen, C. and Westermann, S.
%       (2001). "ICRA Noises: Artificial noise signals with speech-like
%       spectral and temporal properties for hearing instrument
%       assessment," International Journal of Audiology, 40(3), 148-157.  
% 
%   See also schroeder.

%   Developed with Matlab 8.3.0.532 (R2014a). Please send bug reports to:
%   
%   Author  :  Tobias May, (c) 2015
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2015/02/09
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS
% 
% 
% Check for proper input arguments
if nargin < 2 || nargin > 5
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default parameter
if nargin < 3 || isempty(winSec);   winSec   = 20E-3; end
if nargin < 4 || isempty(overlap);  overlap  = 0.875; end
if nargin < 5 || isempty(bShuffle); bShuffle = false; end

% Determine size of input signal
[nSamples,nChannels] = size(input);

% Check for proper size
if nChannels > 1     
    error('Single-channel input required.')
end


%% STFT PROCESSING
% 
% 
% Configure STFT framework
P = configSTFT(fsHz,winSec,overlap,'hann','wola');

% Compute STFT representation
spec = stft(input,fsHz,P);

% Determine size of spectrum
[nRealFreqs,nFrames] = size(spec);


%% RANDOMIZE PHASE
% 
% 
if bShuffle
    % Shuffle original phase values
    if rem(P.nfft,2)
        % Random indices
        [~,rIdx] = sort(rand(nRealFreqs-1,nFrames),1);
        
        % Two-sided spectrum is odd, only DC is unique
        phase_Mod = angle(spec(rIdx + 1));    
        phase_DC  = angle(spec(1,:));    
        phase_NY  = [];
    else
        % Random indices
        [~,rIdx] = sort(rand(nRealFreqs-2,nFrames),1);
        
        % Two-sided spectrum is even, DC and Nyquist are unique
        phase_Mod = angle(spec(rIdx + 1));
        phase_DC  = angle(spec(1,:));    
        phase_NY  = angle(spec(end,:));    
    end
else
    % Replace original phase with randomized phase
    if rem(P.nfft,2)
        % Two-sided spectrum is odd, only DC is unique
        phase_Mod = 2 * pi * rand(nRealFreqs-1,nFrames) - pi;
        phase_DC  = (rand(1,nFrames) > 0.5) * pi; % Can be either 0 or pi
        phase_NY  = [];
    else
        % Two-sided spectrum is even, DC and Nyquist are unique
        phase_Mod = 2 * pi * rand(nRealFreqs-2,nFrames) - pi;
        phase_DC  = (rand(1,nFrames) > 0.5) * pi; % Can be either 0 or pi
        phase_NY  = (rand(1,nFrames) > 0.5) * pi; % Can be either 0 or pi
    end
end

% Add DC, positive frequencies and Nyquist 
phase_Mod = cat(1,phase_DC,phase_Mod,phase_NY);

% Obtain new spectrum using modified phase
specMod = abs(spec) .* exp(1j * phase_Mod);


%% GO BACK TO TIME DOMAIN
% 
% 
% Inverse STFT
out = istft(specMod,P,nSamples);

