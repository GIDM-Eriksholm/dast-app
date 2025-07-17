function [noise,speech,refLTAS] = createSMN(fsHz,durSec,rootSMN,rootLTAS,nFiles,winSec)
%createSMN   Create speech-modulated noise (SMN) with LTAS adjustment
% 
%USAGE
%   [noise,speech,refLTAS] = createSMN(fsHz,durSec,rootSMN)
%   [noise,speech,refLTAS] = createSMN(fsHz,durSec,rootSMN,rootLTAS,nFiles,winSec)
%
%INPUT ARGUMENTS
%       fsHz : sampling frequency in Hertz
%     durSec : duration of the noise in seconds
%    rootSMN : string specifying the root directory with audio files which
%              are used to create the speech-modulated noise   
%   rootLTAS : string specifying the root directory with audio files which
%              are used for LTAS equalization. Alternatively, root can be
%              an audio signal with dimensions [nSamples x 1]. 
%              (default, rootLTAS = rootSMN)  
%     nFiles : limit the number of audio files used for LTAS equalization.
%              If empty, all detected audio files will be used 
%              (default, nFiles = [])
%     winSec : window length in seconds used for LTAS calculation. A longer
%              window provides a higher resolution at low frequencies and
%              thus a more accuracte match with respect to the rootLTAS
%              (default, winSec = 128E-3)
% 
%OUTPUT ARGUMENTS
%     noise : speech-modulated noise [round(fsHz*durSec) x 1]
%    speech : original speech signal [round(fsHz*durSec) x 1]
%   refLTAS : LTAS template structure
% 
%REFERENCES
%   [1] Dreschler, W. A., Verschuure, H., Ludvigsen, C. and Westermann, S.
%       (2001). "ICRA Noises: Artificial noise signals with speech-like
%       spectral and temporal properties for hearing instrument
%       assessment," International Journal of Audiology, 40(3), 148-157.  
% 
%   See also createSSN.

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
if nargin < 3 || nargin > 6
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values 
if nargin < 5 || isempty(winSec);   winSec   = 128E-3;  end
if nargin < 4 || isempty(nFiles);   nFiles   = [];      end
if nargin < 3 || isempty(rootLTAS); rootLTAS = rootSMN; end


%% CONFIGURE PARAMETERS
% 
% 
winType  = 'hann'; % STFT analysis window
nOct     = 3;      % Perform 1/nOct octave smoothing of the LTAS
orderFIR = [];     % Order of FIR equalization filter


%% CREATE SPEECH-MODULATED NOISE
% 
% 
% Scan folder for audio files
allFiles = listFiles(rootSMN,'*.wav');

if numel(allFiles) == 0
    error('No audio files detected! Check "rootSMN"')
end
        
% Allocate memory
speech = [];

% Concatenate speech files
while (length(speech)/fsHz) < durSec
   
    % Check if enough files are available
    if numel(allFiles) < 1
        error('Not enough audio files available! Decrease "durSec"');
    end

    % Random index
    rIdx = rnsubset(1,numel(allFiles));
    
    % Load file
    speech = cat(1,speech,readAudio(allFiles(rIdx).name,fsHz));
    
    % Remove selected file from file list
    allFiles(rIdx) = [];
end

% Trim speech
nSamples = round(fsHz*durSec);
speech = speech(1:nSamples);

% Transform speech into noise while preserving the temporal fluctuations
noise = smn(speech,fsHz,'3channel_butter');


%% CREATE REFERENCE LONG-TERM AVERAGE SPECTRUM (LTAS)
% 
% 
% Measure the LTAS across a predefined number of reference signals
refLTAS = ltasTemplate(rootLTAS,fsHz,nFiles,winSec,winType,nOct);


%% ADJUST LTAS
% 
% 
% Adjust LTAS of stationary noise to the reference LTAS 
noise = ltasEqualize(refLTAS,noise,fsHz,orderFIR);


%% FADE-IN & OUT
% 
% 
% Taper signal
noise = fade(noise,fsHz,4E-3);
