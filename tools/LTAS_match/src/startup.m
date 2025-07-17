function startup(setup)
%startupSTFT   Initialize framework


%% INITIALIZE SETUP
% 
% 
% Detect root directory
rootDir = fileparts(which(mfilename));


%% INSTALL REPOSITORY
% 
% 
% Add local folders
addpath([rootDir,filesep,'demos'])
addpath([rootDir,filesep,'tools'])