clear
close all
clc

% Reset random generator
rng(0);


%% PARAMETERS
% 
% 
% Sampling frequency in Hertz
fsHz = 16E3;

% Select audio root directory for the masker files
rootMasker = ['..',filesep,'..',filesep,'multi_talker_babble',filesep,'masker',filesep];

% Select audio root directory for LTAS calculation
rootLTAS = ['..',filesep,'..', filesep, 'multi_talker_babble',filesep,'target',filesep];

% Number of audio files used to create the target LTAS, if empty, all
% detected files will be used
nFiles = [];

% LTAS parameters
winSec   = 128E-3; % Window size used for LTAS calculation
winType  = 'hann'; % STFT analysis window
nOct     = 3;      % Perform 1/nOct octave smoothing of the LTAS
orderFIR = [];     % Order of FIR equalization filter

% Normalize each masker to this RMS value 
theRMSdB = -26;

% Binary flag indicating if multi-talker wave files should be saved
bStoreWave = true;


%% CREATE REFERENCE LONG-TERM AVERAGE SPECTRUM (LTAS)
% 
% 
% Measure the LTAS across a predefined number of reference signals
refLTAS = ltasTemplate(rootLTAS,fsHz,nFiles,winSec,winType,nOct);


%% CREATE MULTI-TALKER MIXTURE
% 
% 
% Detect number of subfolders
allMaskers = listDirs(rootMasker);
nMaskers = numel(allMaskers);

% Allocate memort
audioFiles = cell(nMaskers,1);
nSamples = zeros(nMaskers,1);
nFiles = inf;

% Loop over all maskers
for ii = 1 : nMaskers
    
    % Detect audio files 
    allFiles = listFiles(allMaskers(ii).name,'*.wav');

    % Randomize files
    audioFiles{ii} = {allFiles(randperm(numel(allFiles))).name};
    
    % Track number of files
    nFiles = min(nFiles,numel(audioFiles{ii}));
end

% Loop over the number of files
for hh = 1 : nFiles
    
    % Initialization
    audio = repmat({[]},[1 nMaskers]);
    nSamplesMax = inf;
    
    % Loop over all maskers
    for ii = 1 : nMaskers
        
        % Read audio
        audio{ii} = readAudio(audioFiles{ii}{hh},fsHz);
        
        % Track maximum number of samples
        nSamplesMax = min(nSamplesMax,size(audio{ii},1));
    end
    
    % Post-process all maskers
    for ii = 1 : nMaskers
        
        % Trim signal
        audio{ii} = audio{ii}(1:nSamplesMax);
        
        % Adjust LTAS
        audio{ii} = ltasEqualize(refLTAS,audio{ii},fsHz);
        
        % Taper mixture
        audio{ii} = fade(audio{ii},fsHz,4E-3);
        
        % Normalize audio to a predefined RMS level
        audio{ii} = setLevelRMS(audio{ii},theRMSdB);
    end
    
    % Multi-talker mixture
    mix = mean(cell2mat(audio),2);
    
    % Adjust LTAS
    mix = ltasEqualize(refLTAS,mix,fsHz);
    
    % Taper mixture
    mix = fade(mix,fsHz,4E-3);

    % Save mixture
    if bStoreWave
        audiowrite(['multi_talker_mixture_',num2str(hh),'.wav'],mix,fsHz);
    end
end

    
%% SHOW RESULTS
% 
% 
% Create colormap
cMap = colormapVoicebox(3);

% Calculate LTAS
[ltassdB,fHz] = ltas(mix,fsHz,refLTAS.winSec,refLTAS.overlap,...
    refLTAS.winType,refLTAS.nOct);

tSec = (0:nSamplesMax-1)'/fsHz;

figure;
hold on;
for ii = 1 : nMaskers
   plot(tSec,audio{ii});
end
grid on;
xlabel('Time (s)')
ylabel('Amplitude')

figure;
h = semilogx(refLTAS.freqHz,refLTAS.LTASdB,fHz,ltassdB);
for ii = 1 : numel(h)
    set(h(ii),'color',cMap(ii,:),'linewidth',1.5);
end
grid on;
xlabel('Frequency (Hz)')
ylabel('LTAS (dB)')
legend({'target' 'multi-talker maskers'},'location','southwest')
axis tight;


%% STORE NOISE SIGNAL
% 
% 
% Create a wavefile, if desired
if 0
    audiowrite('multi_talker_mixture.wav',mix,fsHz);
end
