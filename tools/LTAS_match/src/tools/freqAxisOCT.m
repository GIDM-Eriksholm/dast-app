function [fCenter,fLow,fHigh] = freqAxisOCT(fRangeHz,nOct,fBaseHz,oBase)
%freqAxisOCT   Create octave-spaced frequency axis.
% 
%USAGE
%   [fCenter,fLow,fHigh] = freqAxisOCT(fRangeHz)
%   [fCenter,fLow,fHigh] = freqAxisOCT(fRangeHz,nOct,fBaseHz,oBase)
% 
%INPUT ARGUMENTS
%   fRangeHz : lower and upper frequency limit in Hertz
%       nOct : number of center frequencies per octave 
%              (default, nOct = 1)
%    fBaseHz : base frequency in Hz around which all other frequencies are
%              centered (default, fBaseHz = 1000)  
%      oBase : octave ratio base which can be either 10 or 2 
%              (default, oBase = 2)
% 
%OUTPUT ARGUMENTS
%   fCenter : center frequencies in Hertz
%      fLow : lower edge (3dB) frequencies in Hertz
%     fHigh : higher edge (3dB) frequencies in Hertz
% 
%EXAMPLE
%   % Create 1/3 octave frequency axis between 50 and 4000 Hz
%   freqAxisOCT([50 4000],3)
% 
%REFERENCES
%   [1] IEC 61260 (1995–08): Electroacoustics – Octave-Band and Fractional-
%       Octave-Band filters. 
% 
%   See also freqAxis and freqAxisLOG.

%   Developed with Matlab 8.3.0.532 (R2014a). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2015
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2015/04/05
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
if nargin < 2 || isempty(nOct);    nOct    = 1;   end
if nargin < 3 || isempty(fBaseHz); fBaseHz = 1E3; end
if nargin < 4 || isempty(oBase);   oBase   = 2;   end

% Check frequency range
if min(fRangeHz) <= 0
    error('Lower frequency limit must be larger than 0 Hz.')
end


%% CREATE OCTAVE-SPACED FREQUENCY AXIS
% 
% 
% Range of indices
x = round(-20*nOct):round(20*nOct);

% Octave ratio base
switch(oBase)
    case 2
        G = 2;
    case 10
        G = 10^(3/10);
    otherwise
        error('Invalid octave ratio base.')
end
    
% Check if "nOct" is even or odd
if rem(nOct,2)
    % Odd, compute exact midband frequencies
    fCenter = (G.^(x / nOct)) * fBaseHz;
else
    % Even, compute exact midband frequencies
    fCenter = (G.^((2 * x + 1) / (2*nOct))) * fBaseHz;
end

% Select center frequencies within pre-defined frequency range
idxSelect = find(fCenter <= max(fRangeHz) & fCenter >= min(fRangeHz));

if idxSelect(1) == 1
    error('Increase the lower frequency limit or the range of indices.')
end

% Lower and higher 3dB edge frequencies are determined by geometric means
fLow    = sqrt(fCenter(idxSelect) .* fCenter(idxSelect - 1));
fHigh   = sqrt(fCenter(idxSelect) .* fCenter(idxSelect + 1));
fCenter = fCenter(idxSelect);
