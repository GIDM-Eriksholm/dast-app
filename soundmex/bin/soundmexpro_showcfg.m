%
%                    Example for usage of SoundMexPro
%               Copyright 2023 Daniel Berg, Oldenburg, Germany
%
% SoundMexPro helper script showing the current SoundMexPro channel/track
% configuration of an initialized SoundMexPro instance
%
% NOTE: lower track listbox shows one line for each initialized track
% showing:
%       TRACK     Output          Inputs
% where
% TRACK     = SoundMexPro track index
% Output    = Output channel, where track is connected to. Here the
%             SoundMexPro index is shown followed by the corresponding 
%             channel name returned from driver
% Inputs    = comma delimted lists of input channel indices whose data are
%             copied to the track. NOTE: these indices are SoundMexPro
%             indices depending on init sequence. See upper input channel
%             listbox to get correspinding soundcard channel names.
% -------------------------------------------------------------------------
function soundmexpro_showcfg()

% must be initialized to show current configuration
[success, isinit] = soundmexpro('initialized');
if success ~= 1
   error('error calling initialized command');
end;
if isinit ~= 1
   error('script can only be used if SoundMexPro is initialized');
end;

% create figure
smp_config_show;

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
chnlListBoxI = findobj('Tag','chnlListBoxI');
for i=1:length(channelsO)
    channelsO{i} = sprintf('%2d: %s', i-1, channelsO{i});
end
for i=1:length(channelsI)
    channelsI{i} = sprintf('%2d: \t%s', i-1, channelsI{i});
end
set(chnlListBoxO, 'String', channelsO);
set(chnlListBoxI, 'String', channelsI);


% retrieve track mapping
[success, trackmap] = soundmexpro('trackmap');
if success ~= 1
   error('error calling trackmap command');
end;

% create cell array for strings in track list view
textTrackMap = cell(length(trackmap), 1);
% create cell array input mappings
arrayInputs = cell(length(trackmap), 1);

% retrieve input mapping for each input
for i=1:length(channelsI)
    [success, iostatus] = soundmexpro('iostatus', 'input', i-1);
    if success ~= 1
        error('error calling iostatus command');
    end;
    % store inputs that are mapped to this track
    for y=1:length(iostatus)
		  tmp = arrayInputs{iostatus(y)+1};
		  % append with/without comma
        if (isempty(tmp))
				tmp = num2str(i-1);
		  else 	
			   tmp = [tmp ',' num2str(i-1)];
        end
        arrayInputs{iostatus(y)+1} = tmp;
    end
end
% set '-' for input mapping if empty
for i=1:length(trackmap)
    if isempty(arrayInputs{i})
       arrayInputs{i} = '-';
    end
end

% print complete track info to track listbox
for i=1:length(trackmap)
    str = sprintf('%3d    %-40s %s', i-1, char(channelsO(trackmap(i)+1)), char(arrayInputs{i}) );
    textTrackMap{i} = str;
end
trackListBox = findobj('Tag','trackListBox');
set(trackListBox, 'String', textTrackMap);

   

% -------------------------------------------------------------------------
% function creating GUI 
% -------------------------------------------------------------------------
function smp_config_show()

% close figure if already there
hFig = findobj('Tag','SoundMexProShowConfig');
if (hFig ~= 0)
    close(hFig);
end;

hFig = figure( ... %'Color',[0.831372549019608 0.815686274509804 0.784313725490196], ...
	'MenuBar','none', ...
	'Name','SoundMexPro Configuration Viewer', ...
	'Units','normalized', ...
	'Position',[0.1 0.3 0.4 0.5], ...
	'Tag','SoundMexProShowConfig', ...
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
    'Position',[0.01 0.89 0.4 0.05  ],...
    'Style','text',...
    'BackgroundColor', [1 1 1], ...
    'String', 'Output Channels (Index: Name)', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Courier New', ...
    'Value',1 ...
    );
h = uicontrol(...
    'Parent',hFig,...
    'Units','points',...
    'Units','normalized', ...
    'Position',[0.51 0.89 0.4 0.05  ],...
    'Style','text',...
    'BackgroundColor', [1 1 1], ...
    'String', 'Input Channels (Index: Name)', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Courier New', ...  
    'Value',1 ...
    );

h = uicontrol(...
    'Parent',hFig,...
    'BackgroundColor', [1 1 1], ...
	 'Units','normalized', ...
    'Position',[0.01 0.62 0.48 0.28],...
    'Style','listbox',...
    'Max', 2, ...
    'Value',[],...
    'FontName', 'Courier New', ...
    'Tag','chnlListBoxO'...
    );
h = uicontrol(...
    'Parent',hFig,...
    'BackgroundColor', [1 1 1], ...
	 'Units','normalized', ...
    'Position',[0.51 0.62 0.48 0.28],...
    'Style','listbox',...
    'Max', 2, ...
    'Value',[],...
    'FontName', 'Courier New', ...
    'Tag','chnlListBoxI'...
    );

h = uicontrol(...
    'Parent',hFig,...
    'Units','points',...
	 'Units','normalized', ...
    'Position',[0.01 0.55 0.98 0.05  ],...
    'Style','text',...
    'BackgroundColor', [1 1 1], ...	    
	 'String', 'Track  Output                                   Inputs', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Courier New', ...
    'Value',1, ...
    'Tag', 'textTrackColumns' ...
    );

uicontrol(...
    'Parent',hFig,...
    'BackgroundColor', [1 1 1], ...
	'Units','normalized', ...
    'Position',[0.01 0.01 0.98 0.55],...
    'Style','listbox',...
    'Max', 2, ...
    'Value',[],...
    'FontName', 'Courier New', ...
    'Tag','trackListBox'...
    );


