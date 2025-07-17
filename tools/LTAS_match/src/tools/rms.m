function theRMS = rms(input,dim)
%rms   Calculate the root mean squared value.
% 
%USAGE
%   theRMS = rms(input)
%   theRMS = rms(input,dim)
% 
%INPUT ARGUMENTS
%   input : input signal 
%     dim : dimension along which the RMS should be calculated
% 
%OUTPUT ARGUMENTS
%   theRMS : RMS value

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
if nargin < 1 || nargin > 2
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 2 || isempty(dim); dim = findDim(input); end


%% CALCULATE THE ROOT MEAN SQAURED VALUE
% 
% 
% Calculate the RMS
theRMS = sqrt(mean(input .* conj(input), dim));

