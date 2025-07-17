function out = scaleData(in,STATS)
%scaleData   Scale data according to normalization parameters.
%
%USAGE
%     out = scaleData(in,STATS)
%   
%INPUT ARGUMENTS
%      in : data matrix arranged as [nSamples x nChannels]
%   STATS : structure array created by normalizeData.m with the following
%           fields 
%           .method - normalization method
%           .dim    - dimension 
%           .data   - normalization statistics 
% 
%OUTPUT ARGUMENTS
%     out : scaled data [nSamples x nChannels]
% 
%   See also normalizeData.
% 
%NOTE
%   When training a classifier with features, this function is typically
%   used in combination with the function normalizeData: First, the
%   feature matrix is normalized during training. Then, the normalization
%   statistics measured during training are applied during testing to
%   scale the features accordingly. Sharing the same normalization factors
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
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS 
% 
% 
% Check for proper input arguments
if nargin < 2 || nargin > 2
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Check dimensionality of input data
if numel(size(in)) > 2
    error('Input must be two-dimensional.')
end


%% PERFORM NORMALIZATION
% 
%
% Check if supplied normalization factor is a struct
if ~isstruct(STATS) || ...
        ~isfield(STATS,'dim') || ...
        ~isfield(STATS,'method') || ...
        ~isfield(STATS,'data')
    error('STATS must be a struct created by normalizeData.m')
end

% Select normalization method
switch lower(STATS.method)
    case 'mean'
        
        % Check dimension of supplied "stats"
        if all( size(in,setdiff(1:2,STATS.dim)) ~= numel(STATS.data) )
            error('Dimension mismatch between input and normalization factors.')
        end
        
        % Zero mean normalization
        out = bsxfun(@minus,in,STATS.data);
        
    case 'var'
        
        % Check dimension of supplied "stats"
        if all( size(in,setdiff(1:2,STATS.dim)) ~= numel(STATS.data) )
            error('Dimension mismatch between input and normalization factors.')
        end
        
        % Unit variance normalization
        out = bsxfun(@rdivide,in,STATS.data);
        
    case 'meanvar'
        
        % Check dimension of supplied "stats"
        if all( size(in,setdiff(1:2,STATS.dim)) ~= numel(STATS.data)/2 )
            error('Dimension mismatch between input and normalization factors.')
        end
                
        % Zero mean and unit variance normalization
        if STATS.dim == 1
            out = bsxfun(@minus,in,STATS.data(1,:));
            out = bsxfun(@rdivide,out,STATS.data(2,:));
        else
            out = bsxfun(@minus,in,STATS.data(:,1));
            out = bsxfun(@rdivide,out,STATS.data(:,2));
        end
        
        
    case 'max'
        
        % Check dimension of supplied "stats"
        if all( size(in,setdiff(1:2,STATS.dim)) ~= numel(STATS.data) )
            error('Dimension mismatch between input and normalization factors.')
        end
        
        % Check normalization constant
        if any(STATS.data==0) || any(~isfinite(STATS.data))
            error('Normalization constant is zero or not finite')
        end
        
        % Perform maximum normalization
        out = bsxfun(@rdivide,in,STATS.data);
             
    case 'range'

        % Perform range normalization
        if STATS.dim == 1
            out = bsxfun(@minus,in,STATS.data(1,:));
            out = bsxfun(@rdivide,out,STATS.data(2,:)-STATS.data(1,:));
        else
            out = bsxfun(@minus,in,STATS.data(:,1));
            out = bsxfun(@rdivide,out,STATS.data(:,2)-STATS.data(:,1));
        end
                
    case 'heq'
        
         % Check dimension of supplied "stats"
        if all( size(in,setdiff(1:2,STATS.dim)) ~= size(STATS.data.q,setdiff(1:2,STATS.dim)))
            error('Dimension mismatch between input and normalization factors.')
        end
        
        % Allocate memory
        out = zeros(size(in));
        
        if STATS.dim == 1
            % Loop over all rows
            for ii = 1:size(in,2)
                % Handle the case if all input values are almost equal
                if (STATS.data.q(end,ii) - STATS.data.q(1,ii)) < 100 * eps
                    out(:,ii) = 0.5;
                else
                    mask = [true; diff(STATS.data.q(:,ii)) > 0];
                    out(:,ii) = interp1q(STATS.data.q(mask,ii), STATS.data.qT(mask)', in(:,ii));
                end
            end
        else
            % Loop over all rows
            for ii = 1:size(in,1)
                % Handle the case if all input values are almost equal
                if (STATS.data.q(ii,end) - STATS.data.q(ii,1)) < 100 * eps
                    out(ii,:) = 0.5;
                else
                    mask = [true diff(STATS.data.q(ii,:)) > 0];
                    out(ii,:) = interp1q(STATS.data.q(ii,mask)', STATS.data.qT(mask)', in(ii,:)');
                end
            end
        end
        
        % Map the quantiles to the Gaussian distribution
        % using the inverse error function
        out = erfinv(out * 2 - 1);
        
    otherwise
        error('Normalization method "%s" is not supported',STATS.method);
end 


%   ***********************************************************************
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%   ***********************************************************************