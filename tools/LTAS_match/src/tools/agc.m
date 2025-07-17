function [y,factor] = agc(x,fsHz,tauSec,dim,bLink)
%agc   Multi-channel automatic gain control (AGC)
%   The input signal is normalized by its short-term RMS estimated with a
%   first-order IIR low-pass filter.
% 
%USAGE
%   [y,factor] = agc(x,fsHz)
%   [y,factor] = agc(x,fsHz,tauSec,dim,bLink)
%
%INPUT ARGUMENTS
%        x : input signal 
%     fsHz : sampling frequency in Hertz
%   tauSec : time constant in seconds across which the short-term RMS is
%            estimated (default, tauSec = 2)
%      dim : dimension across which the short-term RMS is estimated
%            (default, dim = findDim(x))   
%    bLink : binary flag indicating if multi-channel differences should be
%            preserved by using the maximum RMS across all channels. If
%            false, each channel is processed independently 
%            (default, bLink = false)
% 
%OUTPUT ARGUMENTS
%        y : normalized signal
%   factor : short-term RMS
% 
%   agc(...) plots the input and the normalized output in a new figure.
% 
%   See also setLevelRMS.

%   Developed with Matlab 9.4.0.813654 (R2018a). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2018
%              Technical University of Denmark (DTU)
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2018/05/18
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
if nargin < 3 || isempty(tauSec); tauSec = 2;          end
if nargin < 4 || isempty(dim);    dim    = findDim(x); end
if nargin < 5 || isempty(bLink);  bLink  = false;      end


%% ESTIMATE THE SHORT-TERM RMS
% 
% 
% Convert time constant to first-order low-pass filter coefficient
alpha = tau2Alpha(fsHz,tauSec);

% IIR filter
b = 1-alpha;
a = [1 -alpha];

% Input dimensions
xDim = size(x);
yDim = [xDim(dim) prod(xDim([1:dim-1 dim+1:end]))];

% Reshape signal to a 2D representation
x2D = reshape(x,yDim);

% Initialize filter states using an average of 1 tau
init = mean(x2D(1:min(xDim(dim),round(fsHz * tauSec)),:).^2);

% Power domain filtering
factor = sqrt(filter(b,a,x2D.^2,-a(2)*init,1));


%% PERFORM NORMALIZATION
% 
% 
% Preserve multi-channel differences
if bLink
    % Use maximum scaling factor across all channels
    factor = repmat(max(factor,[],2),[1 yDim(2)]);
end

% Check scaling factor
if any(factor(:)==0) || any(~isfinite(factor(:)))
    error('Short-term RMS is zero or not finite.')
else
    % Scale input signal
    y2D = x2D ./ factor;
end

% Reshape dimensions
y = reshape(y2D,xDim);
factor = reshape(factor,xDim);


%% SHOW RESULTS
% 
% 
% If no output is specified
if nargout == 0
    
   figure;
   ax(1) = subplot(211);
   plot(x2D);
   title('Before AGC')
   
   ax(2) = subplot(212);
   plot(y2D);
   title('After AGC')
   
   linkaxes(ax,'x')
   xlim([1 xDim(dim)])
end
