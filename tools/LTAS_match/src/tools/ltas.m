function [ltasdB,fHz,P] = ltas(input,fsHz,winSec,overlap,winType,nOct)
%ltas   Compute the long-term average spectrum (LTAS)
% 
%USAGE
%   [ltasdB,fHz,P] = ltas(input,fsHz)
%   [ltasdB,fHz,P] = ltas(input,fsHz,winSec,overlap,winType,nOct)
% 
%INPUT ARGUMENTS
%      input : input signal [nSamples x 1]
%       fsHz : sampling frequency in Hz
%     winSec : window length in seconds (default, winSec = 64E-3)
%    overlap : window overlap factor within the range [0 1) 
%              (default, overlap = 0.5)
%    winType : string specifying window type (default, winType = 'hann')
%       nOct : perform 1/nOct octave smoothing. Set nOct = false to
%              deactivate the smoothing (default, nOct = 3)
% 
%OUTPUT ARGUMENTS
%     ltasdB : onesided LTAS in dB [nRealFreq x 1]
%        fHz : frequency vector in Hz [nRealFreq x 1]
%          P : STFT parameter structure
% 
%   ltas(...) plots the LTAS in a new figure.
% 
%EXAMPLE
%   % Load signal (y & Fs)
%   load('handel.mat');
% 
%   % Compute and plot the LTAS
%   ltas(y,Fs);
% 
%   See also ltasTemplate, ltasEqualize and smoothOctave.

%   Developed with Matlab 8.3.0.532 (R2014a). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2014/12/12
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS
% 
% 
% Check for proper input arguments
if nargin < 2 || nargin > 6
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 3 || isempty(winSec);  winSec  = 64E-3;  end
if nargin < 4 || isempty(overlap); overlap = 0.5;    end
if nargin < 5 || isempty(winType); winType = 'hann'; end
if nargin < 6 || isempty(nOct);    nOct    = 3;      end

% Check for proper size
if min(size(input)) > 1
    error('Single-channel input required.')
end


%% CONFIGURE STFT PARAMETERS
% 
% 
% Initialize STFT parameters
P = configSTFT(fsHz,winSec,overlap,winType,'ola');


%% COMPUTE LTAS
%
%
% Compute the short-time discrete Fourier transform
[X,tSec,fHz] = stft(input,fsHz,P); %#ok

% Compute the power spectrum
XPow = (X .* conj(X)) / P.nfft;

% Double positive frequencies to reflect energy of negative frequencies) 
if rem(P.nfft,2)
    % nfft => odd, onesided power spectrum is even, only DC is unique
    XPow(2:end,:) = XPow(2:end,:) * 2;
else
    % nfft => even, onesided power spectrum is odd, DC and Nyquist are
    % unique 
    XPow(2:end-1,:) = XPow(2:end-1,:) * 2;
end

% Compute the long-term average spectrum (LTAS) by averaging across time,
% drop the last frame due to zero-padding
ltas = nanmean(XPow(:,1:end-1), 2);

% Scale LTAS to dB
ltasdB = 10 * log10(ltas);

% Perform 1/nOct octave smoothing
if isfinite(nOct) && nOct > 0
    ltasdB = smoothOctave(ltasdB,fHz,nOct);
end


%% PLOT RESULT
% 
% 
% If no output is specified
if nargout == 0
    figure;hold on;
    h1 = semilogx(fHz,10*log10(XPow));
    h2 = semilogx(fHz,ltasdB);
    hold off;
    grid on;
    set(h1,'linewidth',0.25,'color',[0.65 0.65 0.65])
    set(h2,'linewidth',2,'color',[0 0 0])
    xlim([fHz(1) fHz(end)])
    set(gca,'xscale','log')
    xlabel('Frequency (Hz)')
    ylabel('LTAS (dB)')
end
