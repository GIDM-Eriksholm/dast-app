function fHz = freqAxis(fsHz,nfft,fRange)
%freqAxis   Create linear frequency axis in Hertz.
%
%USAGE
%   fHz = freqAxis(fsHz,nfft)
%   fHz = freqAxis(fsHz,nfft,fRange)
%
%INPUT ARGUMENTS
%     fsHz : sampling frequency in Hz
%     nfft : number of frequency points
%   fRange : string specifying the range of the frequency axis
%            'onesided' - frequency range [0, fsHz/2], fHz => [nfft/2+1 x 1] 
%            'twosided' - frequency range [0, fsHz),   fHz => [nfft x 1] 
%            (default, fRange = 'onesided')
% 
%OUTPUT ARGUMENTS
%   fHz : frequency axis in Hz [nfft/2+1 x 1 | nfft x 1]
% 
%EXAMPLE
%   fHz = freqAxis(16E3,32)
% 
%   See also freqAxisLOG and freqAxisOCT.

%   Developed with Matlab 7.4.0.287 (R2007a). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2014
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :  
%   v.0.1   2008/05/11
%   v.0.2   2009/10/21 cleaned up
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
if nargin < 3 || isempty(fRange); fRange = 'onesided'; end


%% CREATE FREQUENCY AXIS
% 
% 
% Select frequency range
switch lower(fRange)
    case 'onesided'
        % Frequency vector [0, fsHz/2]
        fHz = (0:fix(nfft/2))'/fix(nfft/2)/2 * fsHz;
    case 'twosided'
        % Frequency vector [0, fsHz)
        fHz = (0:nfft-1)'/(nfft) * fsHz;
    otherwise
        error(['Frequency range "',lower(fRange),'" is not supported.'])
end


%   ***********************************************************************
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%   ***********************************************************************