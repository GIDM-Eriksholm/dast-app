function [y,STATS] = normalizeData(x,method,dim)
%normalizeData   Normalize input data.
%
%USAGE
%   [y,STATS] = normalizeData(x)
%   [y,STATS] = normalizeData(x,method,dim)
%   
%INPUT ARGUMENTS
%        x : data matrix arranged as [nSamples x nChannels]
%   method : string specifying normalization method
%               'mean' - normalize data to have zero mean
%                'var' - normalize data to have unit variance
%            'meanvar' - normalize data to have zero mean and unit variance
%                'max' - normalize data to its maximum
%              'range' - normalize data such that it ranges between [0 1]
%                'heq' - histogram equalization 
%                        (default, METHOD = 'meanvar')
%      dim : dimension along which the input data should be normalized
% 
%OUTPUT ARGUMENTS
%       y : normalized data [nSamples x nChannels]
%   STATS : structure array with the following fields
%           .method - normalization method
%           .dim    - dimension 
%           .data   - normalization statistics 
% 
%   See also scaleData.
% 
%ACKNOWLEDGEMENT
%   The histogram equalization has been adopted from Marc René Schädler's
%   reference feature implementation available at github: 
%   https://github.com/m-r-s/reference-feature-extraction
%
%NOTE
%   When training a classifier with features, this function is typically
%   used in combination with the function scaleData:  First, the feature
%   matrix is normalized during training. Then, the normalization
%   statistics measured during training are applied during testing to scale
%   the features accordingly. Sharing the same normalization factors
%   ensures that a particular feature value has the same relevance in the
%   training and the testing stage.   
% 
%   % Create 2D feature matrix
%   featureSpace = randn(10,250);
%
%   % Split data into training and testing set
%   fTrain = featureSpace(:,1:100);
%   fTest  = featureSpace(:,101:end);
% 
%   % Normalize feature matrix during training 
%   [fTrainNorm,STATS] = normalizeData(fTrain,'meanvar',2);
%
%   % Normalize feature matrix during testing using the normalization
%   % statistics measured during training
%   fTestNorm = scaleData(fTest,STATS);


%   Developed with Matlab 8.3.0.532 (R2014a). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2015
%              Technical University of Denmark (DTU)
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2015/02/25
%   v.0.2   2015/05/27 added histogram equalization
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
if nargin < 2 || isempty(method); method = 'meanvar';  end
if nargin < 3 || isempty(dim);    dim    = findDim(x); end

% Check dimensionality of input data
if numel(size(x)) > 2
    error('Input data must be one or two-dimensional.')
end

% Flag for standard deviation computation (scaled by N - 1)
stdFlag = 0;


%% PERFORM NORMALIZATION
% 
% 
% Create normalization structure
STATS = struct('method',method,'dim',dim,'data',[]);

% Select normalization method
switch lower(method)
    case 'mean'
        
        % Compute mean
        STATS.data = mean(x,dim);
        
        % Zero mean normalization
        y = bsxfun(@minus,x,STATS.data);
        
    case 'var'
       
        % Compute standard deviation
        STATS.data = std(x,stdFlag,dim);
        
        % Prevent division by zero
        STATS.data(STATS.data == 0) = 1;
        
        % Check normalization factors
        if any(~isfinite(STATS.data))
            error('Normalization factors are not finite.')
        end
        
        % Unit variance normalization
        y = bsxfun(@rdivide,x,STATS.data);
        
    case 'meanvar'
        
        % Compute mean and standard deviation
        STATS.data = mean(x,dim);
        STATS.data = cat(dim,STATS.data,std(x,stdFlag,dim));
        
        % Prevent division by zero
        if dim == 1
            STATS.data(2,STATS.data(2,:) == 0) = 1;
        else
            STATS.data(STATS.data(:,2) == 0,2) = 1;
        end
        
        % Zero mean and unit variance normalization
        if dim == 1
            y = bsxfun(@minus,x,STATS.data(1,:));
            y = bsxfun(@rdivide,y,STATS.data(2,:));
        else
            y = bsxfun(@minus,x,STATS.data(:,1));
            y = bsxfun(@rdivide,y,STATS.data(:,2));
        end
        
    case 'max'
        
        % Compute maximum value
        STATS.data = max(x,[],dim);
        
        % Prevent division by zero
        STATS.data(STATS.data == 0) = 1;
            
        % Check normalization factors
        if any(~isfinite(STATS.data))
            error('Normalization factors are not finite.')
        end
        
        % Perform maximum normalization
        y = bsxfun(@rdivide,x,STATS.data);
        
    case 'range'
        
        % Compute minimum and maximum value
        STATS.data = min(x,[],dim);
        STATS.data = cat(dim,STATS.data,max(x,[],dim));
        
        % Perform range normalization
        if dim == 1
            y = bsxfun(@minus,x,STATS.data(1,:));
            y = bsxfun(@rdivide,y,STATS.data(2,:)-STATS.data(1,:));
        else
            y = bsxfun(@minus,x,STATS.data(:,1));
            y = bsxfun(@rdivide,y,STATS.data(:,2)-STATS.data(:,1));
        end
             
    case 'heq'
        
        % Number of uniform intervals
        nQuantiles = 100;
                         
        % Calculate the expected minimum and maximum quantiles
        % when drawing 'context' samples from the unknown distribution
        % C.f. Equation 4 in [1]
        context = size(x,dim);
        
        exptected_min = 1-context./(context+1);
        exptected_max = context./(context+1);
        
        % Define source and target quantiles
        STATS.data.qS = linspace(0, 1, nQuantiles);
        STATS.data.qT = linspace(exptected_min, exptected_max, nQuantiles);
        
        % Get source quantiles from data
        STATS.data.q = quantile(x, STATS.data.qS, dim);
        
        % Allocate memory
        y = zeros(size(x));
        
        if dim == 1
            % Loop over all rows
            for ii = 1:size(x,2)
                % Handle the case if all input values are almost equal
                if (STATS.data.q(end,ii) - STATS.data.q(1,ii)) < 100 * eps
                    y(:,ii) = 0.5;
                else
                    mask = [true; diff(STATS.data.q(:,ii)) > 0];
                    y(:,ii) = interp1q(STATS.data.q(mask,ii), ...
                        STATS.data.qT(mask)', x(:,ii));
                end
            end
        else
            % Loop over all rows
            for ii = 1:size(x,1)
                % Handle the case if all input values are almost equal
                if (STATS.data.q(ii,end) - STATS.data.q(ii,1)) < 100 * eps
                    y(ii,:) = 0.5;
                else
                    mask = [true diff(STATS.data.q(ii,:)) > 0];
                    y(ii,:) = interp1q(STATS.data.q(ii,mask)', ...
                        STATS.data.qT(mask)', x(ii,:)');
                end
            end
        end
        
        % Map the quantiles to the Gaussian distribution
        % using the inverse error function
        y = erfinv(y * 2 - 1);
        
    otherwise
        error('Normalization method "%s" is not supported.',method);
end 

