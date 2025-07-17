function minIdx = argmin(input, dim)
%argmin   Indices of smallest elements in array

% Check for proper input arguments
if nargin < 1 || nargin > 2
    help(mfilename);
    error('Wrong number of input arguments!')
end

if nargin < 2 || isempty(dim)
    [temp, minIdx] = min(input);
else
    [temp, minIdx] = min(input,[],dim);
end
