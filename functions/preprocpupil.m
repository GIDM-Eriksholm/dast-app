function [Diameter,Metadata] = preprocpupil(RawDiameter,Param)
%PREPROCPUPIL preprocesses pupillometry data based on the parameters
%defined in Param. First, it sets values before and after NaNs to NaN in order to
%get rid of transient artifacts before and after blinks. Second, it linearly interpolates
%missing values. 
%
%   Inputs:
%       RawDiameter: One-dimensional vector with values and NaNs as missing
%       values
%       Param: Structure with some necessary parameters, for example: 
%           Param.Fs = 50; % [Hz]: Sampling rate of pupil data 
%           Param.RemoveBeforeAndAfter = [35 100]*1e-3; % [s]: Samples within the time range before and after NaNs will set NaNs as well
%           Param.MinLengthNaNRepair = 1; % [samples]: Drop values (i.e., change to NaN) before and after NaNs only for contiguous NaNs of at least __ samples. 
%   
%   Outputs: 
%       Diameter: Preprocessed Diameter
%       Metadata: Some information about missing data a.s.o
%           Metadata.IsNanRaw: logic vector of length RawDiameter with 1's at NaNs, 0's otherwise.
%           Metadata.IntactRaw: logic vector of length RawDiameter with 1's at values and 0's at NaNs.


% Make sure its a column vector
if size(RawDiameter,2) > size(RawDiameter,1)
    RawDiameter = RawDiameter';
end
% Make sure it is only one column
if size(RawDiameter,2) > 1
    error('Please use a one-dimensional vector')
end

L = length(RawDiameter); % Length

% Get some meta data
Metadata.Time = ((0:(L-1))/Param.Fs)'; % Create a time vector starting at 0
Metadata.IsnanRaw = isnan(RawDiameter); % Get missing samples
Metadata.IntactRaw = ~Metadata.IsnanRaw; % Get intact samples
Metadata.ContigNan = findcontigval(RawDiameter,nan); % find contiguous NaNs (clusters).

LengthContigNan = diff(Metadata.ContigNan,1,2)+1; % Get the length of each cluster.
RemoveContigNan = Metadata.ContigNan(find(LengthContigNan >= Param.MinLengthNanRepair),:); % Only consider clusters at least as long as defined

% Widen the window as defined
RemoveContigNan(:,1) = RemoveContigNan(:,1) - ceil(Param.RemoveBeforeAndAfter(1)*Param.Fs);
RemoveContigNan(:,2) = RemoveContigNan(:,2) + ceil(Param.RemoveBeforeAndAfter(2)*Param.Fs);

% Truncate indices to beginning and end of pupil diameter;
RemoveContigNan = max(RemoveContigNan,1);
RemoveContigNan = min(RemoveContigNan,length(RawDiameter));

% Set values to NaN
Diameter = RawDiameter;
Metadata.SetNan = ~isnan(nan(size(Diameter)));
for idx = 1:size(RemoveContigNan,1)
    Metadata.SetNan(RemoveContigNan(idx,1):RemoveContigNan(idx,2)) = 1;
end

Diameter(Metadata.SetNan) = nan;

% Collect missing values
Metadata.Isnan = isnan(Diameter);
Metadata.Intact = ~Metadata.Isnan;

if sum(Metadata.Intact) > 1

    % Interpolate
    Diameter(Metadata.Isnan) = interp1(Metadata.Time(Metadata.Intact),Diameter(Metadata.Intact),Metadata.Time(Metadata.Isnan));
    
    % Find persistent NaNs at the beginning (or end) of Diameter and replace
    % with first (or last) available value
    EdgeNans = findcontigval(Diameter,nan);
    
    % Check if it is at the beginning or end and choose value accordingly
    for idx = 1:size(EdgeNans,1)
        if EdgeNans(idx,1) == 1
            Diameter(EdgeNans(idx,1):EdgeNans(1,2)) = Diameter(EdgeNans(idx,2)+1);
        elseif EdgeNans(idx,2) == L
            Diameter(EdgeNans(idx,1):EdgeNans(idx,2)) = Diameter(EdgeNans(idx,1)-1);
        end
    end
else
    warning('No data left after removal of samples.')
end

end

