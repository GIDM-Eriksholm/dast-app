function out = schroeder(in,p)
%schroeder   Flip the sign of "p" percent of the input samples.
%   This process will maintain the temporal fluctuations in the input,
%   while the resulting signal has a flat (white) spectrum [1,2]. If the
%   input signal is speech, the output is unintelligible.  
% 
%USAGE
%   out = schroeder(in)
%   out = schroeder(in,p)
%
%INPUT ARGUMENTS
%   in : input signal [nSamples x nChannels x ... ]
%    p : percentage of input samples which should flip their sign 
%        (default, p = 0.5)
% 
%OUTPUT ARGUMENTS
%   out : output signal [nSamples x nChannels x ... ]
% 
%REFERENCES
%   [1] Schroeder, M. R. (1968). "Reference signal for signal quality
%       studies," The Journal of the Acoustical Society of America, 44(6),
%       1735-1736. 
%  
%   [2] Dreschler, W. A., Verschuure, H., Ludvigsen, C. and Westermann, S.
%       (2001). "ICRA Noises: Artificial noise signals with speech-like
%       spectral and temporal properties for hearing instrument
%       assessment," International Journal of Audiology, 40(3), 148-157.  
% 
%   See also randPhase.

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
if nargin < 1 || nargin > 2
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values 
if nargin < 2 || isempty(p); p = 0.5; end


%% PERFORM SCHROEDER PROCESSING
% 
% 
% Dimensionality of input 
dim = size(in);

% Randomly change the sign of "p" percentage of all samples
out = in .* (2 * (rand(dim) > p) - 1);

