%
%                    Example for usage of SoundMexPro
%               Copyright 2023 Daniel Berg, Oldenburg, Germany
%
% Tool script for SoundMexPro showing all available ASIO drivers and
% corresponding output and input channels. Click any driver name to see
% available channels.
% If 'Ok' button is clicked, the currently selected driver name, vector
% with output channels and vector with input channels are returned. These
% return values may be used directly as arguments for the 'init'
% parameters 'driver', 'input' and 'output' respectively.
% -------------------------------------------------------------------------

function [driver, outchannels, inchannels] = soundmexpro_showdevs(driver_def, outchannels_def, inchannels_def)

% SoundMexPro must not be initialized when calling script
[success, isinit] = soundmexpro('initialized');
if success ~= 1
    error('error calling initialized command');
end;
if isinit ~= 0
    error('script can only be used if SoundMexPro is not initialized');
end;

% set default arguments
if nargin < 1
    driver_def = [];
end
if nargin < 2
    outchannels_def = [];
end
if nargin < 3
    inchannels_def = [];
end

hfig = smp_config_show();
smp_showdrivers(driver_def);
% if afterwards a driver is preselected, then we show the selected
% channels as well
if ~isempty(smp_getseldriver)
    smp_showchannels(outchannels_def, inchannels_def);
end

% wait for figure either to be closed, or 'uiresume' called by ok button
uiwait(hfig);

% assign driver output argument
if (nargout > 0)
    driver = smp_getseldriver;
    if isempty(driver)
        driver  = [];
    end
end

% assign output channels argument
if (nargout > 1)
    hList = findobj('Tag','chnlListBoxO');
    if hList == 0
        error('cannot find configurator channel list');
    end
    outchannels = get(hList, 'Value') - 1; % -1: SoundMexPro channnels are zero based!
    if isempty(outchannels)
        outchannels  = [];
    end
end

% assign input channels argument
if (nargout > 2)
    hList = findobj('Tag','chnlListBoxI');
    if hList == 0
        error('cannot find configurator channel list');
    end
    inchannels = get(hList, 'Value') - 1; % -1: SoundMexPro channnels are zero based!
    if isempty(inchannels)
        inchannels = [];
    end
end

% close figure, if still there
hfig = findobj('Tag','SoundMexProShowDevs');
if (hfig ~= 0)
    close(hfig);
end




% -------------------------------------------------------------------------
%               SUBFUNCTIONS BELOW
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Adds all driver names to driver listbox and does preselection
% -------------------------------------------------------------------------
function smp_showdrivers(driver)
drvBox = findobj('Tag','drvListBox');
if drvBox == 0
    error('cannot find Driver combo box');
end

% query soundmexpro for drivers
[success, drivers] = soundmexpro('getdrivers');
if success ~= 1
    error('error calling getdrivers command');
end;
set(drvBox, 'String', drivers);

% try to convert non-numerical (name of driver) to it's index
if ~isnumeric(driver)
    [drv, driver] = max(strncmp(driver, drivers, length(driver)));
    driver = driver -1;
end

% pre-select driver if not empty
if ~isempty(driver)
    set(drvBox, 'Value', driver+1);
    smp_showchannels;
end


% -------------------------------------------------------------------------
% Adds all input and output channels to corresponding listboxes and
% does preselection
% -------------------------------------------------------------------------
function smp_showchannels(outchannels, inchannels)

% here directly disable multiselection in driver listbox
drvBox = findobj('Tag','drvListBox');
if drvBox == 0
    error('cannot find Driver combo box');
end
set(drvBox, 'Min', 1);
set(drvBox, 'Max', 1);

% clear lists
hListO = findobj('Tag','chnlListBoxO');
if hListO == 0
    error('cannot find configurator channel list');
end
set(hListO, 'String', '');
set(hListO, 'Value', []);

% input channels
set(hListO, 'String', '');
hListI = findobj('Tag','chnlListBoxI');
if hListI == 0
    error('cannot find configurator channel list');
end
set(hListI, 'String', '');
set(hListI, 'Value', []);

% retrieve channels from SoundMexPro
[success, channelsO, channelsI] = soundmexpro('getchannels', 'driver', smp_getseldriver);
if success ~= 1
    [success, errstr] = soundmexpro('getlasterror');
    % write error to selection boxes ad return
    set(hListO, 'String', errstr);
    set(hListI, 'String', errstr);
    return;
end;

% list output channels
set(hListO, 'String', channelsO);
% list input channels
set(hListI, 'String', channelsI);

% now do preselection if requested AND within range
if ((nargin > 0) && (length(outchannels) > 0))
    if (min(outchannels) >= 0 && max(outchannels) < length(channelsO))
        set(hListO, 'Value', outchannels+1);
    end
end
if ((nargin > 1) && (length(inchannels) > 0))
    if (min(inchannels) >= 0 && max(inchannels) < length(channelsI))
        set(hListI, 'Value', inchannels+1);
    end
end

% -------------------------------------------------------------------------
% callback for driver listbox. Calls smp_showchannels without arguments
% -------------------------------------------------------------------------
function smp_showcurrentchannels(varargin)
    smp_showchannels;

% -------------------------------------------------------------------------
% returns name of currently selected driver in driver listbox
% -------------------------------------------------------------------------
function driver = smp_getseldriver()
drvBox = findobj('Tag','drvListBox');
if drvBox == 0
    error('cannot find Driver listbox');
end
curDrv = get(drvBox, 'String');
curDrv = curDrv(get(drvBox, 'Value'));
if (nargout > 0)
    driver = char(curDrv);
end;


% -------------------------------------------------------------------------
% function sets global variables with current selections and closes figure
% -------------------------------------------------------------------------
function smp_okbutton(varargin)
% close figure
hFig = findobj('Tag','SoundMexProShowDevs');
if (hFig ~= 0)
    x = smp_getseldriver
   close(hFig);
end

% -------------------------------------------------------------------------
% function creating GUI
% -------------------------------------------------------------------------
function f = smp_config_show()

% close figure if already there
hFig = findobj('Tag','SoundMexProShowDevs');
if (hFig ~= 0)
    close(hFig);
end

hFig = figure( ...
    'MenuBar','none', ...
    'Name','SoundMexPro Configuration Tool', ...
    'Units','normalized', ...
    'Position',[0.1 0.5 0.4 0.4], ...
    'Tag','SoundMexProShowDevs', ...
    'Resize', 'off', ...
    'WindowStyle', 'normal', ...
    'ToolBar','none');

uicontrol(...
    'Parent',hFig,...
    'Units','points',...
    'Units','normalized', ...
    'Position',[0.01 0.94 0.3 0.05  ],...
	 'BackgroundColor', [1 1 1], ...
    'Style','text',...
    'String', 'Available ASIO Drivers', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Courier New', ...
    'Value',1 ...
    );
uicontrol(...
    'Parent',hFig,...
    'Units','points',...
    'Units','normalized', ...
    'Position',[0.01 0.59 0.4 0.05  ],...
	 'BackgroundColor', [1 1 1], ...
    'Style','text',...
    'String', 'Available Output Channels', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Courier New', ...
    'Value',1 ...
    );
uicontrol(...
    'Parent',hFig,...
    'Units','points',...
    'Units','normalized', ...
    'Position',[0.51 0.59 0.4 0.05  ],...
	 'BackgroundColor', [1 1 1], ...
    'Style','text',...
    'String', 'Available Input Channels', ...
    'HorizontalAlignment', 'left', ...
    'FontName', 'Courier New', ...
    'Value',1 ...
    );

uicontrol(...
    'Parent',hFig,...
    'BackgroundColor', [1 1 1], ...
    'Units','normalized', ...
    'Position',[0.01 0.12 0.46 0.48],...
	 'BackgroundColor', [1 1 1], ...
    'Style','listbox',...
    'Min', 0, ...
    'Max', 1000, ...
    'Value',[],...
    'FontName', 'Courier New', ...
    'Tag','chnlListBoxO'...
    );
uicontrol(...
    'Parent',hFig,...
    'BackgroundColor', [1 1 1], ...
    'Units','normalized', ...
    'Position',[0.51 0.12 0.48 0.48],...
	 'BackgroundColor', [1 1 1], ...
    'Style','listbox',...
    'Min', 0, ...
    'Max', 1000, ...
    'Value',[],...
    'FontName', 'Courier New', ...
    'Tag','chnlListBoxI'...
    );

uicontrol(...
    'Parent',hFig,...
    'Units','normalized', ...
    'Position',[0.01 0.02 0.98 0.08],...
	 'BackgroundColor', [1 1 1], ...
    'Style','pushbutton',...
    'Value',1,...
    'String', 'Ok', ...
    'callback', 'uiresume(gcbf)', ... % call function 'okbutton'
    'Tag','btnPush'...
    );

uicontrol(...
    'Parent',hFig,...
    'BackgroundColor', [1 1 1], ...
    'Units','normalized', ...
    'Position',[0.01 0.67 0.98 0.28],...
    'Style','listbox', ...
    'Min', 0, ... % initially allow multiselect: will be changed later
    'Max', 2, ...
    'Value', [], ...
    'callback', @smp_showcurrentchannels, ... % show channels of selected device
    'FontName', 'Courier New', ...
    'Tag','drvListBox'...
    );

if (nargout > 0)
    f = hFig;
end


