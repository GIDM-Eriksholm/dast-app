function [fHz,nFreq] = freqAxisLOG(fLowHz,fHighHz,nFreq)
%freqAxisLOG   Create a logarithmically-spaced frequency axis in Hertz.
% 
%USAGE
%   [fHz,nFreq] = freqAxisLOG(fLowHz,fHighHz)
%   [fHz,nFreq] = freqAxisLOG(fLowHz,fHighHz,nFreq)
% 
%INPUT ARGUMENTS
%    fLowHz : low frequency limit in Hertz
%   fHighHz : high frequency limit in Hertz
%     nFreq : number of frequencies (default, nFreq = [])
% 
%OUTPUT ARGUMENTS
%     fHz : frequency axis in Hertz
%   nFreq : number of frequencies
% 
%   Starting at the lower frequency limit, frequencies are equidistantly-
%   spaced on the log scale, until the high frequency limit is reached. Due
%   to the constant spacing, the highest frequency may not be included
%   (e.g. freqAxisLOG(1,40)) 
% 
%   If a particular number of frequencies is requested, the spacing between
%   frequencies is adjusted to include both the low and the high frequency
%   limits (e.g. freqAxisLOG(1,40,8)).
% 
%   See also freqAxisOCT and freqAxis.

%   Developed with Matlab 8.3.0.532 (R2014a). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2014/11/26
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
if nargin < 3; nFreq = []; end

% Check frequency range
if fLowHz <= 0
    error('Lower frequency limit must be larger than 0 Hz.')
end


%% CREATE LOGARITHMICALLY-SPACED FREQUENCY AXIS
% 
% 
if ~isempty(fLowHz) && ~isempty(fHighHz) && ~isempty(nFreq)
    % 1. Frequency range and number of filters specified
    fHz = pow2(linspace(log2(fLowHz),log2(fHighHz),nFreq));
elseif ~isempty(fLowHz) && ~isempty(fHighHz) && isempty(nFreq)
    % 2. Only frequency range is specified
    fHz  = pow2(log2(fLowHz):log2(fHighHz));
    nFreq = numel(fHz);
else
    error('Not enough or incoherent input arguments.')
end
