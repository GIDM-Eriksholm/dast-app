function [noise,refLTAS] = createSSN(fsHz,durSec,rootLTAS,nFiles,winSec)
%createSSN   Create speech-shaped noise (SSN)
% 
%USAGE
%   [noise,refLTAS] = createSSN(fsHz,durSec,rootLTAS)
%   [noise,refLTAS] = createSSN(fsHz,durSec,rootLTAS,nFiles,winSec)
%
%INPUT ARGUMENTS
%       fsHz : sampling frequency in Hertz
%     durSec : duration of the noise in seconds
%   rootLTAS : string specifying the root directory with audio files which
%              are used for LTAS calculation. Alternatively, root can be an
%              audio signal with dimensions [nSamples x 1].   
%     nFiles : limit the number of audio files used for LTAS equalization.
%              If empty, all detected audio files will be used 
%              (default, nFiles = [])
%     winSec : window length in seconds used for LTAS calculation. A longer
%              window provides a higher resolution at low frequencies and
%              thus a more accuracte match with respect to the rootLTAS
%              (default, winSec = 128E-3)
% 
%OUTPUT ARGUMENTS
%     noise : speech-shaped noise [round(fsHz*durSec) x 1]
%   refLTAS : LTAS template structure
% 
%   See also createSMN.

%   Developed with Matlab 9.4.0.813654 (R2018a). Please send bug reports to
%   
%   Author  :  Tobias May, (c) 2018
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2018/03/21
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS
% 
% 
% Check for proper input arguments
if nargin < 3 || nargin > 5
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values 
if nargin < 5 || isempty(winSec); winSec = 128E-3; end
if nargin < 4 || isempty(nFiles); nFiles = [];     end


%% CONFIGURE PARAMETERS
% 
% 
winType  = 'hann'; % STFT analysis window
nOct     = 3;      % Perform 1/nOct octave smoothing of the LTAS
orderFIR = [];     % Order of FIR equalization filter


%% CREATE WHITE GAUSSIAN NOISE
% 
% 
% Gaussian noise
nSamples = round(durSec*fsHz);
noiseWhite = randn(nSamples,1);


%% CREATE REFERENCE LONG-TERM AVERAGE SPECTRUM (LTAS)
% 
% 
% Measure the LTAS across a predefined number of reference signals
refLTAS = ltasTemplate(rootLTAS,fsHz,nFiles,winSec,winType,nOct);


%% ADJUST LTAS
% 
% 
% Adjust LTAS of stationary noise to the reference LTAS 
noise = ltasEqualize(refLTAS,noiseWhite,fsHz,orderFIR);


%% FADE-IN & OUT
% 
% 
% Taper signal
noise = fade(noise,fsHz,4E-3);

