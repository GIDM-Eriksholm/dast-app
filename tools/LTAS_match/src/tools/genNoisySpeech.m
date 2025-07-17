function [mix,target,noise,idx] = genNoisySpeech(target,fsHz,noiseType,snrdB,padSec)
%genNoisySpeech   Create noisy speech with constant SNR.
%   
%USAGE
%   [mix,target,noise,idx] = genNoisySpeech(target,fsHz,noiseType,snrdB)
%   [mix,target,noise,idx] = genNoisySpeech(target,fsHz,noiseType,snrdB,padSec)
%
%INPUT ARGUMENTS
%      target : one of the following options
%               1) string or cell array with the name of the target signal
%               2) vector representing the target signal [nSamples x 1]
%        fsHz : sampling frequency in Hz
%   noiseType : string defining the background noise 
%               (see genNoise.m for more details)
%       snrdB : signal-to-noise ratio in dB
%      padSec : duration of zeros that should be padded to the target signal  
%               padSec = [pre] : pad zeros to the beginning of the signal
%               padSec = [pre post] : pad zeros to the beginning and the
%               end of the signal (default, padSec = [0 0])   
% 
%OUTPUT ARGUMENTS
%      mix : noisy mixture [nSamples + padSames x 1]
%   target : target signal [nSamples + padSames x 1]
%    noise : noise signal  [nSamples + padSames x 1]
%      idx : target-active sample range [nSamples x 1]
% 
%   genNoisySpeech(...) plots the three signals in a new figure.
% 
%   See also adjustSNR, zeroPadding and genNoise.

%   Developed with Matlab 8.4.0.150421 (R2014b). Please send bug reports to:
%   
%   Author  :  Tobias May, © 2015
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2015/07/02
%   ***********************************************************************
   
    
%% CHECK INPUT ARGUMENTS  
% 
% 
% Check for proper input arguments
if nargin < 4 || nargin > 5
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 5 || isempty(padSec); padSec = [0 0]; end


%% LOAD TARGET SIGNAL
%
%
% Check if input is a character 
if ischar(target)
    % Load audio file
    target = readAudio(target,fsHz);
elseif iscell(target) && numel(target) == 1
    % Load audio file
    target = readAudio(target{:},fsHz);
end

% Check dimensions
if min(size(target)) > 1
    error('Single-channel audio file required.')
end

% Determine dimensionality
nSamples = numel(target);

% Zero padding in samples
nZeros = round(padSec * fsHz);

% Target-active samples
idx = (1:nSamples)' + nZeros(1);

%% CREATE NOISE 
%
%
% Generate noise
noise = genNoise(noiseType,fsHz,nSamples+sum(nZeros));

    
%% CONTROL THE SIGNAL-TO-NOISE RATIO
%
%
% With zero-padding
if any(nZeros > 0)
    % Calculate gain factor (exclude zero-padding)
    [~,~,~,gain] = adjustSNR(target,noise(idx),snrdB);
    
    % Perform zero-padding
    target = zeroPadding(target,nZeros);
    
    % Adjust the noise level
    noise = noise * gain;
    
    % Create mixture
    mix = target + noise;
else
    % Adjust SNR
    [mix,target,noise] = adjustSNR(target,noise,snrdB);
end


%% SHOW NOISY MIXTURE
%
%
% Plot target, noise and noisy target
if nargout == 0
    
    % Time vector
    samplesSec = (0:numel(mix)-1)/fsHz;
    
    figure;hold on;
    hM = plot(samplesSec,mix);
    hN = plot(samplesSec,noise);
    hS = plot(samplesSec,target);
    grid on;xlim([samplesSec(1) samplesSec(end)]);
    xlabel('Time (s)')
    ylabel('Amplitude')
    set(hM,'color',[0 0 0])
    set(hS,'color',[0 0.5 0])
    set(hN,'color',[0.5 0.5 0.5])
    legend({'mix' 'noise' 'target'})
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