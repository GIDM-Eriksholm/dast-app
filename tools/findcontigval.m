function [BegEndIdx] = findcontigval(X,V)
%FINDCONTIGVAL returns the indices of start and endings of contiguous
%values of V in X.
%  Finds incidences of values V in X and returns indices of start (first columns)
% and ends of contiguous values. Also works for NaNs.  

% Make sure its a column vector
if size(X,2) > size(X,1)
    X = X'
end
% Make sure it is only one column
if size(X,2) > 1
   error('Pleae use a one-dimensional vector') 
end

% Find incidences of V in X
if isnan(V)
   VinX = isnan(X);
else
   VinX = X == V;
end

% Get change of values from 0 to 1 or vice versa
DiffVinX = [diff([0; VinX])];

% A start is an incidence where an incidence of V is preceded by a non-V
%(i.e. diff == 1). An end is an incidence where a V is followed by a 
%non-V (i,e., diff == -1.
BegEndIdx = [find(VinX & DiffVinX) find(VinX & [DiffVinX(2:end);-1] == -1)];

end

