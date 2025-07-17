function out = fade(input,fsHz,durSec)
%fade   Smooth transitions at the beginning and the end with a hann window. 
% 
%USAGE
%   out = fade(input,fsHz)
%   out = fade(input,fsHz,durSec)
%
%INPUT ARGUMENTS
%    input : input signal [nSamples x nChannels]
%     fsHz : sampling frequency in Hertz
%   durSec : duration of the fade-in/fade-out window 
%            (default, durSec = 4E-3)
% 
%OUTPUT ARGUMENTS
%   out : tapered input signal [nSamples x nChannels]

%   Developed with Matlab 9.4.0.813654 (R2018a). Please send bug reports to
%   
%   Author  :  Tobias May, (c) 2018
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2018/04/09
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
if nargin < 3 || isempty(durSec); durSec = 4E-3; end

% Dimensionality
[nSamples,nChannels] = size(input);


%% CREATE WINDOW
% 
% 
% Cosine-tapered window
N = 2 * round(fsHz * durSec / 2);
win = hann(2 * N,'periodic');

% Check signal length
if 2 * N > nSamples
    error('Input signal is too short for the selected window duration.')
end


%% FADE IN & OUT
% 
% 
% Copy signal
out = input;

% Sample range for fade-in and fade-out 
idxIn = 1:N;
idxOut = nSamples-N+1:nSamples;

% Apply the window
out(idxIn,:) = out(idxIn,:) .* repmat(win(1:N),[1 nChannels]);
out(idxOut,:) = out(idxOut,:) .* repmat(flipud(win(1:N)),[1 nChannels]);
