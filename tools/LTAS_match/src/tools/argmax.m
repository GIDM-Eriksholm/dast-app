function maxIdx = argmax(input, dim)
%argmax   Indices of largest elements in array

% Check for proper input arguments
if nargin < 1 || nargin > 2
    help(mfilename);
    error('Wrong number of input arguments!')
end

if nargin < 2 || isempty(dim)
    [temp, maxIdx] = max(input);
else
    [temp, maxIdx] = max(input,[],dim);
end
