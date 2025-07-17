function [x,tSec] = genSin(fsHz,TSec,fHz,A,phi)
%genSin   Create sinusoid with multiple frequency components
% 
%USAGE
%   [x,tSec] = genSin(fsHz)
%   [x,tSec] = genSin(fsHz,TSec,fHz,A,phi)
%  
%INPUT ARGUMENTS
%   fsHz : sampling frequency in Hertz
%   TSec : duration of sinusoid in seconds (default, TSec = 0.1)
%    fHz : vector of frequency components in Hertz (default, fHz = 1E3)
%      A : vector of amplitude values (default, A = ones(size(fHz)))
%    phi : vector of phase values (default, phi = zeros(size(fHz)))
% 
%OUTPUT ARGUMENTS
%      x : sinusoid [fsHz * TSec x 1]
%   tSec : time vector in seconds [fsHz * TSec x 1]
% 
%   genSin(...) plots the sinusoid in a new figure.
% 
%   See also genChirp and genNoise.

%   Developed with Matlab 9.2.0.538062 (R2017a). Please send bug reports to
%   
%   Author  :  Tobias May, © 2017
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2017/08/19
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS
%
%
% Check for proper input arguments
if nargin < 1 || nargin > 5
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 2 || isempty(TSec); TSec = 0.1;              end
if nargin < 3 || isempty(fHz);  fHz  = 1E3;              end
if nargin < 4 || isempty(A);    A    = ones(size(fHz));  end
if nargin < 5 || isempty(phi);  phi  = zeros(size(fHz)); end

% Check if highest f0Hz is below Nyquist 
if max(fHz) > fsHz / 2
    error('Highest frequency component is above Nyquist frequency.')
end


%% CREATE SINUSOID WITH MULTIPLE FREQUENCY COMPONENTS
% 
% 
% Discrete-time vector
Ts = 1 / fsHz;
tSec = (0:Ts:(TSec-Ts))';

% Number of frequency components
nComponents = numel(fHz);

% Number of samples
N = round(TSec * fsHz);

% Allocate memory
x = zeros(N,1);

% Loop over the number of frequency components
for ii = 1 : nComponents
    x = x + A(ii) * sin(2 * pi * fHz(ii) * tSec + phi(ii));
end


%% PLOT SIGNAL
% 
% 
% If no output is specified
if nargout == 0
    figure;
    plot(tSec,x);
    xlabel('Time (s)')
    ylabel('Amplitude')
    xlim([tSec(1) tSec(end)])
end
