function [val,ind] = findNearest(x,y)
%findNearest   Return nearest values and indices of y in x.
%
%USAGE
%   [val,ind] = findNearest(x,y);
%
%INPUT ARGUMENTS
%   x : vector of values
%   y : vector of values which should be found in x
%
%OUTPUT ARGUMENTS
%   val : nearest values of y in x.
%   idx : indices of nearest values of y in x.
%
%EXAMPLE
%   % Create value list
%   x = 0:1E-3:1;
% 
%   % Find closest value of randomized number in x
%   findNearest(x,rand(1))


%% CHECK INPUT ARGUMENTS  
% 
% 
% Check for proper input arguments
if nargin < 2 || nargin > 2
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Check if x and y are vectors
if sum(size(x)>1)>1 || sum(size(y)>1)>1
    error('Inputs "x" and "y" must be vectors.');
end


%% FIND NEAREST MATCH
% 
%
x=x(:);     % make column
y=y(:).';   % make row

[~,ind] = min(abs(y(ones(size(x,1),1),:)-x(:,ones(1,size(y,2)))));

% Get values
val = x(ind);