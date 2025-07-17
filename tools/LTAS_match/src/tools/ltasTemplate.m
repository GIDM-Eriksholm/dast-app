function refLTAS = ltasTemplate(root,fsHz,nSignals,winSec,winType,nOct)
%ltasTemplate   Create a long-term average spectrum (LTAS) template
% 
%USAGE
%     refLTAS = ltasTemplate(root,fsHz)
%     refLTAS = ltasTemplate(root,fsHz,nSignals,winSec,winType,nOct)
%
%INPUT ARGUMENTS
%        root : root directory with audio files. Alternatively, root can
%               be an audio signal with dimensions [nSamples x 1].
%        fsHz : reference sampling frequency in Hz. If the audio files are 
%               sampled at a different rate, they will be resampled prior
%               to LTAS analysis. If root is a signal, fsHz is assumed to
%               be the corresponding sampling frequency.  
%    nSignals : number of randomly selected audio signals used for the LTAS
%               template. If empty, all detected audio files will be used.
%               (default, nSignals = [])
%      winSec : window length in seconds (default, winSec = 128E-3)
%     winType : string specifying window type (default, winType = 'hann')
%        nOct : perform 1/nOct octave smoothing (default, nOct = 3)
% 
%OUTPUT ARGUMENTS
%     refLTAS : LTAS template structure
%              .label     - 'template LTAS'
%              .rootAudio - audio root directory
%              .fileNames - cell array with all audio filenames
%              .fsHz      - reference sampling frequency in Hz
%              .winSec    - window length in seconds
%              .winType   - window type
%              .nOct      - 1/nOct octave smoothing
%              .LTASdB    - reference LTAS in dB [nFFTBins x 1]
%              .freqHz    - frequency vector in Hz [nFFTBins x 1]
% 
%   ltasTemplate(...) plots the template LTAS in a new figure.
% 
%   See also ltasEqualize and ltas.

%   Developed with Matlab 8.3.0.532 (R2014a). Please send bug reports to:
%   
%   Author  :  Tobias May, (c) 2015-2018
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2015/04/08
%   v.0.2   2018/02/25 added octave smoothing
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS
% 
% 
% Check for proper input arguments
if nargin < 2 || nargin > 6
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 3 || isempty(nSignals); nSignals = [];     end
if nargin < 4 || isempty(winSec);   winSec   = 128E-3; end
if nargin < 5 || isempty(winType);  winType  = 'hann'; end
if nargin < 6 || isempty(nOct);     nOct     = 3;      end


%% SCAN ROOT DIRECTORY FOR AUDIO FILES
% 
% 
% Check if root is dir or audio signal
if ischar(root) && isdir(root) %#ok

    % Scan reference root directory
    allFiles = listFiles(root,'*.wav');
    
    % Set default
    if isempty(nSignals)
        nSignals = numel(allFiles);
    end
    
    % Check available sentences
    if nSignals == 0
        error('No audio files detected! Check "root"')
    elseif numel(allFiles) < nSignals
        error('Not enough audio files available! Decrease "nSignals"')
    else
        % Extract file names from randomly selected files
        fileNames = {allFiles(randperm(numel(allFiles),nSignals)).name};
    end
    
    % Set flag to true
    bFiles = true;
    
elseif isnumeric(root)
    
    % Root is the signal
    nSignals = 1;
    
    % Set flag to false
    bFiles = false;
else
    error('Wrong usage of input "root".')
end


%% CREATE TEMPLATE LTAS
% 
% 
% Overlap factor 
overlap = 0.5;
    
% Loop over number of signals
for ii = 1 : nSignals
    
    % Read ii-th signal
    if bFiles
        currSig = readAudio(fileNames{ii},fsHz);
    else
        currSig = root;
    end
    
    % Compute long term average spectrum (LTAS)
    [currLTASdB,freqHz] = ltas(mean(currSig,2),fsHz,winSec,overlap,...
        winType,nOct);
        
    % Allocate memory
    if ii == 1
        LTASdB = zeros(numel(currLTASdB),nSignals);
    end
    
    % Store LTAS
    LTASdB(:,ii) = currLTASdB;
end
    
% Produce template LTAS by averaging across all signals
LTASdBAverage = mean(LTASdB,2);

% Create template structure
if bFiles
    refLTAS = struct('label','LTAS template','rootAudio',root,...
        'fileNames',{fileNames},'fsHz',fsHz,'winSec',winSec,...
        'overlap',overlap,'winType',winType,'nOct',nOct,...
        'LTASdB',LTASdBAverage,'freqHz',freqHz);
else
    refLTAS = struct('label','LTAS template','fsHz',fsHz,...
        'winSec',winSec,'overlap',overlap,'winType',winType,'nOct',nOct,...
        'LTASdB',LTASdBAverage,'freqHz',freqHz);
end


%% PLOT RESULTS
% 
% 
% Show template 
if nargout == 0
    figure;hold on;
    grid on;
    plot(freqHz,LTASdB,'color',[0.5 0.5 0.5]);
    plot(freqHz,LTASdBAverage,'k','linewidth',2);
    set(gca,'xscale','log');
    xlabel('Frequency (Hz)')
    ylabel('LTAS (dB)')
    xlim([10 fsHz/2])
end
