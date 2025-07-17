clear
close all
clc


%% PARAMETERS
% 
% 
% Sampling frequency in Hertz
fsHz = 16E3;

% Select audio root directory 
rootAudio = [pwd,filesep,'..',filesep,'multi_talker_babble',filesep,'target',filesep];

% Normalize each audio file to this RMS value 
theRMSdB = -26;

% Binary flag indicating if wave files should be saved (overw-written)
bStoreWave = true;


%% ADJUST RMS
% 
% 
% Detect number of subfolders
allFiles = listFiles(rootAudio,'*.wav');
nFiles = numel(allFiles);

% Loop over all audio filse
for ii = 1 : nFiles

    % Read audio
    audio = readAudio(allFiles(ii).name,fsHz);
        
    % Adjust RMS
    audio = setLevelRMS(audio,theRMSdB);

    % Check if clipping is likely to occur
    if max(abs(audio)) > 1
        error('Clipping ... reduce "theRMSdB".')
    end
        
    % Save mixture
    if bStoreWave
        audiowrite(allFiles(ii).name,audio,fsHz);
    end
end

