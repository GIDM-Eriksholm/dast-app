function [y,factor] = setLevelRMS(x,RMSdB,dim,bLink)
%setLevelRMS   Set the input signal to a predefined RMS level in dB.
% 
%USAGE
%   [y,factor] = setLevelRMS(x)
%   [y,factor] = setLevelRMS(x,RMSdB,dim,bLink)
% 
%INPUT ARGUMENTS
%       x : input signal 
%   RMSdB : RMS level in dB (default, RMSdB = 0)
%     dim : dimension across which the RMS level is estimated
%           (default, dim = findDim(x))   
%   bLink : binary flag indicating if multi-channel differences should be
%           preserved by using the maximum RMS across all channels. If
%           false, each channel is processed independently 
%           (default, bLink = true)
% 
%OUTPUT ARGUMENTS
%        y : scaled output signal 
%   factor : normalization factor 
% 
%   setLevelRMS(...) plots the input and the scaled output in a new figure
%   if the input signal is one- or two-dimensional. 
% 
%   See also agc.

%   Developed with Matlab 8.2.0.701 (R2013b). Please send bug reports to
%   
%   Author  :  Tobias May, © 2015
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2015/10/15
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS  
% 
% 
% Check for proper input arguments
if nargin < 1 || nargin > 4
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 2 || isempty(RMSdB); RMSdB = 0;          end
if nargin < 3 || isempty(dim);   dim   = findDim(x); end
if nargin < 4 || isempty(bLink); bLink = true;       end


%% DERIVE NORMALIZATION CONSTANT
% 
% 
% Calculate scaling factor across channels
factor = rms(x,dim) * 10.^(-RMSdB/20);

% Preserve multi-channel differences
if bLink
    % Use maximum scaling factor across all channels
    factor = max(factor(:));
end


%% PERFORM NORMALIZATION
% 
% 
% Check scaling factor
if any(factor(:) == 0) || any(~isfinite(factor(:)))
    error('Normalization constant is zero or not finite.')
else
    % Normalize signal 
    y = bsxfun(@rdivide,x,factor);
end


%% SHOW NORMALIZATION
%
%
% If no output is specified
if nargout == 0 && numel(size(x)) < 3
    figure;
    ax(1) = subplot(2,1,1);
    plot(x)
    title('Before scaling')
    ax(2) = subplot(2,1,2);
    plot(y)
    xlabel('Number of samples')
    title('After scaling')
    
    axis tight;
    linkaxes(ax,'x');
end
