%
%                    Example for usage of SoundMexPro
%               Copyright 2023 Daniel Berg, Oldenburg, Germany
%
% SoundMexPro helper script for generating a trackmap for an initialized
% SoundMexPro configuration 
%
% The shown track listbox shows one line for each initialized track
% showing:
%       TRACK     Output          
% where
% TRACK     = SoundMexPro track index
% Output    = Output channel, where track is connected to. Here the
%             SoundMexPro index is shown followed by the corresponding 
%             channel name returned from driver
% At the right all available (initialized) output channels are listed. If
% you select one or more tracks in the left list and select an output
% channel afterwards, all tracks are mapped to that output. If you select
% one track, the currently mapped output channel is selected in the right
% box.
% The function returns the 'generated' trackmap as vector which can
% directly be used as argument for parameter 'track' in command 'trackmap'
% -------------------------------------------------------------------------
function trackmap = soundmexpro_trackmap(varargin)

% must be initialized to show current configuration
[success, isinit] = soundmexpro('initialized');
if success ~= 1
   error('error calling initialized command');
end;
if isinit ~= 1
   error('script can only be used if SoundMexPro is initialized');
end;

% define global variable for return value: needed in case of recurse
% calls 
global Ltrackmap;

% argument parsing 
% a. no argument: show figure
if (isempty(varargin))
    smp_config_show;
    smp_showtracks;
% b. listbox with available output channels calls this function recursively
% with argument 'domaptrack'
 elseif (strcmp(varargin, 'domaptrack'))
    smp_domaptrack;
    return;
% c. listbox with tracks calls this function recursively
% with argument 'showmaptrack'
 elseif (strcmp(varargin, 'showmaptrack'))
    smp_showmaptrack;
    return;
% d. pushbutton 'Ok' calls this function recursively with argument 'okbutton'
elseif (strcmp(varargin, 'okbutton'))
    smp_okbutton;
    return;
else
    error('unknown argument(s) passed');
end

% wait for figure to closed manually, or by recurse call to smp_okbutton
uiwait;

% assign outarg
trackmap = Ltrackmap;

% clear global variable
clear Ltrackmap;


% -------------------------------------------------------------------------
% function that reads current trackmap from initialized SoundMexPro
% instance
% -------------------------------------------------------------------------
function smp_showtracks()
% retrieve current driver
[success, actdrv] = soundmexpro('getactivedriver');
if success ~= 1
   error('error calling getactivedriver command');
end;
curDrvText = findobj('Tag','curDrvText');
set(curDrvText, 'String', ['Active ASIO driver: ' char(actdrv)]);

% retrieve active channels
[success, channelsO, channelsI] = soundmexpro('getactivechannels');
if success ~= 1
   error('error calling getactivechannels command');
end;
% prepend SoundMexPro channel index to names returned from driver
% and write active channels to corresponding list boxes
chnlListBoxO = findobj('Tag','chnlListBoxO');
for i=1:length(channelsO)
    channelsO{i} = sprintf('%2d: %s', i-1, channelsO{i});
end
set(chnlListBoxO, 'String', channelsO);


% retrieve track mapping
[success, trackmap] = soundmexpro('trackmap');
if success ~= 1
   error('error calling trackmap command');
end;

% create cell array for strings in track list view
textTrackMap = cell(length(trackmap), 1);
% create cell array input mappings
arrayInputs = cell(length(trackmap), 1);


% print complete track info to track listbox
for i=1:length(trackmap)
    str = sprintf('%3d    %s', i-1, char(channelsO(trackmap(i)+1)) );
    textTrackMap{i} = str;
end
trackListBox = findobj('Tag','trackListBox');
set(trackListBox, 'String', textTrackMap);

% -------------------------------------------------------------------------
% function that changes track mapping of one or more tracks in track
% listbox according to current selection in (called when clicking on output
% channels list)
% -------------------------------------------------------------------------
function smp_domaptrack()

% retrieve currently selected channel, track(s) and string in track list
hChannelList = findobj('Tag','chnlListBoxO');
if hChannelList == 0
    error('cannot find configurator channel list');
end
hTrackList = findobj('Tag','trackListBox');
if hTrackList == 0
    error('cannot find track list');
end
selChannel = get(hChannelList, 'Value');
selTracks =  get(hTrackList, 'Value');
% if no output channel or tracks selected then nothing to do
if (isempty(selTracks))
    return;
end
if (isempty(selChannel))
    return;
end
% get selected output channel string
channelO = get(hChannelList, 'String');
channelO = channelO{selChannel};
currentmap = get(hTrackList, 'String');
% adjust selected cells
for i=1:length(selTracks)
    str = sprintf('%3d    %s', selTracks(i)-1, channelO );
    currentmap{selTracks(i)} = str;
end
% and write string back to listbox
set(hTrackList, 'String', currentmap);


% -------------------------------------------------------------------------
% function that selects the output channel that corresponds to current
% selection in track listbox
% -------------------------------------------------------------------------
function smp_showmaptrack()
% get selected track
hTrackList = findobj('Tag','trackListBox');
if hTrackList == 0
    error('cannot find track list');
end
selTrack =  get(hTrackList, 'Value');
if (length(selTrack) ~= 1)
    return;
end
currenttrack = get(hTrackList, 'String');
currenttrack = currenttrack{selTrack};

% get available channel strings
hChannelList = findobj('Tag','chnlListBoxO');
if hChannelList == 0
    error('cannot find configurator channel list');
end
channels  = get(hChannelList, 'String');
% search for particular channel string within current track string
for i=1:length(channels)
    if (~isempty(strfind(currenttrack, channels{i})))
       set(hChannelList, 'Value', i); 
       break;
    end
end

% -------------------------------------------------------------------------
% function sets global variable with current trackmap
% -------------------------------------------------------------------------
function smp_okbutton()
global Ltrackmap;

% get track list
hTrackList = findobj('Tag','trackListBox');
if hTrackList == 0
    error('cannot find track list');
end
tracks = get(hTrackList, 'String');
Ltrackmap = [];
% go through all tracks and extract mapping
for i=1:length(tracks)
    % NOTE: each line is like
    %   0   ?: CHANNELNAME
    % where ? is the neeed track. So we so scanf to two integers and use
    % the second
    track = sscanf(tracks{i}, '%d %d');
    Ltrackmap = [Ltrackmap track(2)];
end

% close figure
hFig = findobj('Tag','SoundMexProTrackMap');
if (hFig ~= 0)
   close(hFig);
end

% -------------------------------------------------------------------------
% function creating GUI 
% -------------------------------------------------------------------------
function smp_config_show()

% close figure if already there
hFig = findobj('Tag','SoundMexProTrackMap');
if (hFig ~= 0)
    close(hFig);
end;

hFig = figure( ...
	'MenuBar','none', ...
	'Name','SoundMexPro Configuration Viewer', ...
	'Units','normalized', ...
	'Position',[0.1 0.3 0.4 0.4], ...
	'Tag','SoundMexProTrackMap', ...
    'Resize', 'off', ...
   'ToolBar','none');

h = uicontrol(...
    'Parent',hFig,...
    'Units','points',...
	 'Units','normalized', ...
    'Position',[0.01 0.93 0.98 0.05  ],...
	 'BackgroundColor', [1 1 1], ...
    'Style','text',...
    'String', '', ...
    'HorizontalAlignment', 'left', ...
    'Value',1, ...
    'FontName', 'Courier New', ...
    'Tag', 'curDrvText' ...
    );
h = uicontrol(...
    'Parent',hFig,...
    'Units','points',...
	 'Units','normalized', ...
    'Position',[0.01 0.88 0.4 0.05  ],...
	 'BackgroundColor', [1 1 1], ...
    'Style','text',...
    'String', 'Track   Output Channel', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Courier New', ...
    'Value',1 ...
    );
h = uicontrol(...
    'Parent',hFig,...
    'Units','points',...
	 'Units','normalized', ...
    'Position',[0.6 0.88 0.4 0.05  ],...
	 'BackgroundColor', [1 1 1], ...
    'Style','text',...
    'String', 'Available Output Channels', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Courier New', ...
    'Value',1 ...
    );

h = uicontrol(...
    'Parent',hFig,...
    'BackgroundColor', [1 1 1], ...
	 'Units','normalized', ...
    'Position',[0.6 0.12 0.39 0.77],...
	 'BackgroundColor', [1 1 1], ...
    'Style','listbox',...
    'Value',1,...
    'FontName', 'Courier New', ...
    'callback', 'soundmexpro_trackmap(''domaptrack'')', ... % recurse call to main function
    'Tag','chnlListBoxO'...
    );

uicontrol(...
    'Parent',hFig,...
    'BackgroundColor', [1 1 1], ...
	 'Units','normalized', ...
    'Position',[0.01 0.12 0.58 0.77],...
	 'BackgroundColor', [1 1 1], ...
    'Style','listbox',...
    'Max', 2, ...
    'Value',[],...
    'FontName', 'Courier New', ...
    'callback', 'soundmexpro_trackmap(''showmaptrack'')', ... % recurse call to main function
    'Tag','trackListBox'...
    );

uicontrol(...
    'Parent',hFig,...
    'Units','normalized', ...
    'Position',[0.01 0.02 0.98 0.08],...
	 'BackgroundColor', [1 1 1], ...
    'Style','pushbutton',...
    'Value',1,...
    'Max', 1000, ...
    'String', 'Ok', ...
    'callback', 'soundmexpro_trackmap(''okbutton'')', ... % recurse call to main function
    'Tag','btnPush'...
    );

