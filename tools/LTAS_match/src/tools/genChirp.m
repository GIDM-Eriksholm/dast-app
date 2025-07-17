function [x,tSec] = genChirp(fsHz,f0Hz,TSec,f1Hz,phi0)
%genChirp   Create a linear chirp signal
% 
%USAGE
%   [x,t] = genChirp(fsHz)
%   [x,t] = genChirp(fsHz,f0Hz,TSec,f1Hz,phi0)
%  
%INPUT ARGUMENTS
%   fsHz : sampling frequency in Hertz
%   f0Hz : instantaneous frequency in Hertz at time 0 (default, f0Hz = 0)
%   TSec : duration of chirp in seconds (default, TSec = 0.2)
%   f1Hz : instantaneous frequency in Hertz at time TSec (default, fsHz / 2)
%   phi0 : phase offset (default, phi0 = 0)
% 
%OUTPUT ARGUMENTS
%      x : linear chirp signal [fsHz * TSec x 1]
%   tSec : time vector in seconds [fsHz * TSec x 1]
% 
%   genChirp(...) plots the chirp signal in a new figure.
% 
%   See also genSin and genNoise.

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
if nargin < 5 || isempty(phi0); phi0 = 0;        end
if nargin < 4 || isempty(f1Hz); f1Hz = fsHz / 2; end
if nargin < 3 || isempty(TSec); TSec = 200E-3;   end
if nargin < 2 || isempty(f0Hz); f0Hz = 0;        end


%% CREATE CHIRP SIGNAL
% 
% 
% Discrete-time vector
Ts = 1 / fsHz;
tSec = (0:Ts:(TSec-Ts))';

% Rate of frequency change
k = (f1Hz - f0Hz) / TSec;

% Create chirp signal
x = cos(2 * pi * (f0Hz .* tSec + k/2 .* tSec.^2) + phi0);


%% PLOT SIGNAL
% 
% 
% If no output arguments are specified
if nargout == 0
    figure;
    plot(tSec,x);
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('Linear chirp signal')
    xlim([tSec(1) tSec(end)])
end
