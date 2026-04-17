function Y = padfilter(X,FilterWin)
%PADFILTER pads the data with length(FilterWin) samples of the first value (at beginning) and last value
%(at the end) to minimize edge artificats of data with non-zero mean.
%   Detailed explanation goes here
NPadValues = length(FilterWin);

if size(X,1) < size(X,2)
    X = X';
end

X = [repmat(X(1),NPadValues,1); X; repmat(X(end),NPadValues,1)];

X = conv(X,FilterWin,'same');

Y = X((NPadValues+1):(end-NPadValues));

end

