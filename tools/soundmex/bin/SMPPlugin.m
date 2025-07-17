%
%  Helper script for compiling MATLAB realtime plugins for SoundMexPro
%               Copyright 2023 Daniel Berg, Oldenburg, Germany
%
% This script can be used for ALL your compiled plugins, only the command
% line for compiling has to be adjusted:
%
% Compile your plugin using the command line
%
%    mcc -m -a FILE1 -a FILE1 ... -a mpluginmex SMPPlugin
%
% where FILE1, FILE2 are all scripts needed by the plugin (start script, 
% processing script and - for spectral plugins - your stft user function . 
% If you are compiling a spectral script plugin be sure to include the 
% STFT shipped with SoundMexPro as well
%
%   -a smp_stft 
% 
% If you don't use any GUI in the plugin then you may specify the "-R -nojvm" 
% as well.
% To use the compiled EXE rather than a second MATLAB instance created by
% default by SoundMexPro you must specify the exe name on init of
% SoundMexPro with parameter
%   'pluginexe', 'SMPPlugin.exe'
%
% You may rename the file and function name to get different EXEs for different 
% plugins. Do NOT change the content of the function!!
%
% Important hint: it is not easy to debug such EXE plugins, because there
% is no MATLAB workspace window available and thus usually you cannot even
% see the output to the prompt. To gain more information you may use the
% following trick during the development:
% - specify a batch file calling the EXE rather than the EXE itself, e.g. 
%       'pluginexe', 'testbatch.bat'
% - pipe ALL arguments to the exe, and pipe statdard out  and standard error
%   to a file
%       SMPLugin.exe %* >plugin_output.txt 2>&1
%
% Then you can call your application and check plugin_output.txt for errors.
% Additionally the used plugin mex MPLUGINMEX will send OutputDebugStrings
% on errors, thus you may use any OutputDebugString-Viewer to check for the
% messages
%

function SMPPlugin(varargin)
    % do not change this: extracts substtring starting with 'mpluginmex'
    % from first argument and call eval for resulting string
    args = varargin{1};
    eval(args(findstr(args, 'mpluginmex'):end));
end