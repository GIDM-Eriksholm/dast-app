function [outputArg1,outputArg2] = plotmeansem(X,Data,Color,AX)
%PLOTMEANSEM plots the mean and standard error of the mean. The mean and 
% SEM will be calculated across the 2nd dimension, such that length(X) 
% should be the same as size(Data,1) 
% Inputs: 
%       X: X-axis, for example a timevector
%   	Data: the data with the dimension 
%
%       AX: Axis handle 
if length(X) ~= size(Data,1)
    error('Size of first Dimension in Data must match length of X')
end
if size(X,2) > size(X,1)
    X = X';
end

MEAN = mean(Data,2,"omitmissing");
SEM = std(Data,[],2,"omitmissing")/sqrt(size(Data,2));
%figure
hold(AX,'on')
plot(AX, X,Data,'Color',Color,'handlevisibility','off','LineWidth',.2);
fill(AX, [X; flipud(X)],[MEAN+SEM; flipud(MEAN-SEM)],Color,'Edgecolor','none','Facealpha',0.3,'handlevisibility','off')
plot(AX, X,MEAN,'Color',Color,"LineWidth",4)
hold(AX,'off')

end

