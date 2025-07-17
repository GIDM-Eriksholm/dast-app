function y = movingAverage(x,winSize,dim)
%movingAverage   Perform moving average data smoothing.
% 
%USAGE
%   y = movingAverage(x)
%   y = movingAverage(x,winSize,dim)
% 
%INPUT ARGUMENTS
%         x : input data arranged as [nSamples x nChannels]
%   winSize : size of the symmetric, rectangular moving average window,
%             winSize must be odd (default, winSize = 3)
%       dim : dimension across which the moving average is computed
%             (default, dim = findDim(input))
% 
%OUTPUT ARGUMENTS
%   y : smoothed input data [nSamples x nChannels]
% 
%   movingAverage(...) plots the smoothed data in a new figure. 
% 
%EXAMPLE
%   % Smooth random data sequence 
%   movingAverage(rand(100,1));

%   Developed with Matlab 8.6.0.267246 (R2015b). Please send bug reports to:
%
%   Author  :  Tobias May, © 2015
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.1.0   2015/10/05
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS  
% 
% 
% Check for proper input arguments
if nargin < 1 || nargin > 3
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 3 || isempty(dim);     dim     = findDim(x); end
if nargin < 2 || isempty(winSize); winSize = 3;          end

% Determine dimensionality of x
xdim = size(x);

% Check dimensionality
if numel(xdim) > 2
    error('Input data may be one or two-dimensional.')
end

% Check if winSize is a scalar
if ~isscalar(winSize)
    error('The moving average window size "winSize" must be a scalar!')
end

% Check if winSize is odd
if rem(winSize,2) == 0 
    error('The moving average window size "winSize" must be odd!')
end

% Check if enough data is available 
if winSize > xdim(dim)
    error(['The moving average window size "winSize" is larger than ',...
        'the number of available data points.'])
end


%% DESIGN MOVING AVERAGE FILTER
% 
% 
% Filter
b = ones(winSize,1) / winSize;
a = 1;


%% APPLY MOVING AVERAGE FILTER
% 
% 
% Perform smoothing
y = filter(b,a,x,[],dim);

% Take care of edges
if dim == 1
    edgeL = cumsum(x(1:winSize-2,:),dim);
    edgeL = edgeL(1:2:end,:)./repmat((1:2:(winSize-2))',...
        [1 xdim(setdiff(1:2,dim))]);
    edgeR = cumsum(x(xdim(dim):-1:xdim(dim)-winSize+3,:),dim);
    edgeR = edgeR(end:-2:1,:)./repmat((winSize-2:-2:1)',...
        [1 xdim(setdiff(1:2,dim))]);
    
    y = cat(1,edgeL,y(winSize:end,:),edgeR);
else
    edgeL = cumsum(x(:,1:winSize-2),dim);
    edgeL = edgeL(:,1:2:end)./repmat((1:2:(winSize-2)),...
        [xdim(setdiff(1:2,dim)) 1]);
    edgeR = cumsum(x(:,xdim(dim):-1:xdim(dim)-winSize+3),dim);
    edgeR = edgeR(:,end:-2:1)./repmat((winSize-2:-2:1),...
        [xdim(setdiff(1:2,dim)) 1]);
    
    y = cat(2,edgeL,y(:,winSize:end),edgeR);
end


%% SHOW RESULTS
% 
% 
% If no output is specified
if nargout == 0
   figure;hold on;grid on;
   if dim == 1
       plot(x(:,1),'-','color',[0.5 0.5 0.5])
       plot(y(:,1),'k-','linewidth',1.5)
   else
       plot(x(1,:),'-','color',[0.5 0.5 0.5])
       plot(y(1,:),'k-','linewidth',1.5)
   end
   xlabel('Number of samples')
   ylabel('Amplitude')
   legend({'input (1st channel)' 'output (1st channel)'})
   title('Moving average filtering')
end
