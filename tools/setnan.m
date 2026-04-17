function [Diameter,Metadata] = setnan(RawDiameter,Param)
%SETTONAN sets values in RawDiameter to NaN based on criteria defined in the structure Param. 
%   Detailed explanation goes here
%
%   Inputs:
%       RawDiameter: One-dimensional vector with values and NaNs as missing
%       values
%       Param: Structure with some necessary parameters, for example: 
%           Param.Range = .1 1; % [mm] or [Pixels]: Set values outside this range to NaN
%           Param.RangeQuantile = true; If true, Range is interpreted as
%           quantile and should be between 0 and 1.
%           Param.DiffThresh = 0.9; % [mm] or [Pixels]: If the difference
%           from one sample to the next sample exceeds this thereshold, both samples
%           will be set to NaN.
%           Param.DiffQuantile = true; If true, DiffThresh is interpreted
%           as quantile and should be between 0 and 1.
%   Outputs: 
%       Diameter: NaN'ed Diameter
%       Metadata: Some information about missing data a.s.o
%           Metadata.IsNanRaw: loigcal vector indicating where the raw data
%           had NaN's
%           Metadata.Range: Which range criteria was applied to the data.
%           Metadata.SetNanRange: logical vector with 1's indicating which 
%           samples were set to NaN because of range criterion.
%           Metadata.DiffThresh: Which difference criterion was applied to the data.
%           Metadata.SetNanDiff: logical vector with 1's indicating which 
%           samples were set to NaN because of difference criterion.

% Make sure its a column vector
if size(RawDiameter,2) > size(RawDiameter,1)
    RawDiameter = RawDiameter';
end

% Make sure it is only one column
if size(RawDiameter,2) > 1
    error('Please use a one-dimensional vector')
end

% Make sure Range is [min max]
if Param.Range(1) >= Param.Range(2) || length(Param.Range) ~= 2 
    error('Please provide a range vector with two elements where Range(1) < Range(2)')
end
% Make sure that quatiles are interpretable
if Param.RangeQuantile && (Param.Range(1) < 0 || Param.Range(2) > 1)
    error('Please provide a range vector with two elements where Range(1) < Range(2) and Range(1) >= 0 and Range(2) <= 1')
end

% Get missing samples of raw data
Metadata.IsNanRaw = isnan(RawDiameter); 

% Apply range criterion
if ~Param.RangeQuantile
    Metadata.Range = Param.Range;
elseif Param.RangeQuantile
    SortDiameter = sort(RawDiameter(~Metadata.IsNanRaw));
    Metadata.Range = SortDiameter(round(Param.Range*length(SortDiameter)));
end
Metadata.SetNanRange = RawDiameter < Metadata.Range(1)| RawDiameter > Metadata.Range(2);

% Apply difference criterion
Diff = abs(diff(RawDiameter)); % Calculate aboslite difference
if ~Param.DiffQuantile
    Metadata.DiffThresh = Param.DiffThresh;
elseif Param.DiffQuantile
    SortDiff = sort(Diff(~isnan(Diff)));
    Metadata.DiffThresh = SortDiff(round(Param.DiffThresh*length(SortDiff)));
end
Metadata.SetNanDiff = [Diff > Metadata.DiffThresh | [0; Diff(1:(end-1))] > Metadata.DiffThresh; 0];

% Set samples to NaN that either meet the range or the difference criterion
Metadata.SetNan = Metadata.SetNanRange | Metadata.SetNanDiff;
RawDiameter(Metadata.SetNan) = nan;
Diameter = RawDiameter;

end

