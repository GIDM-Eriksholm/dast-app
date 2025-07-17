function [out,firLTAS] = ltasEqualize(refLTAS,input,fsHz,orderFIR)
%ltasEqualize   Adjust the input signal LTAS to the template LTAS
% 
%USAGE
%   [out,firLTAS] = ltasEqualize(refLTAS,input,fsHz)
%   [out,firLTAS] = ltasEqualize(refLTAS,input,fsHz,orderFIR)
%
%INPUT ARGUMENTS
%    refLTAS : reference LTAS template structure (see ltasTemplate)
%      input : input signal [nSamples x 1]
%       fsHz : sampling frequency in Hz
%   orderFIR : order of the FIR equalization filter. If not specified, the
%              filter order will be automatically calculated depending on
%              the spectral resolution of the LTAS template. 
% 
%OUTPUT ARGUMENTS
%       out : input signal with adjusted LTAS [nSamples x 1]
%   firLTAS : FIR filter coefficients [orderFIR x 1]
% 
%   See also ltasTemplate and ltas.

%   Developed with Matlab 8.3.0.532 (R2014a). Please send bug reports to:
%   
%   Author  :  Tobias May, (c) 2015
%              Technical University of Denmark
%              tobmay@elektro.dtu.dk
%
%   History :
%   v.0.1   2015/04/08
%   ***********************************************************************


%% CHECK INPUT ARGUMENTS
% 
% 
% Check for proper input arguments
if nargin < 3 || nargin > 4
    help(mfilename);
    error('Wrong number of input arguments!')
end

% Set default values
if nargin < 4 || isempty(orderFIR)
    orderFIR = pow2(ceil(log2(numel(refLTAS.freqHz))));
end


%% MEASURE LTAS OF INPUT SIGNAL
% 
% 
% Resample input, if required
input = resample(input,refLTAS.fsHz,fsHz);

% Measure LTAS of input signal
inputLTASdB = ltas(mean(input,2),refLTAS.fsHz,refLTAS.winSec,...
    refLTAS.overlap,refLTAS.winType,refLTAS.nOct);


%% DERIVE LTAS EQUALIZATION FILTER
% 
% 
% Normalized frequency axis ranging from 0 to fsHz/2
freqNorm = refLTAS.freqHz/(refLTAS.fsHz/2);

% Linear spectrum difference between template and current target LTAS
equalizeLTAS = 10.^((refLTAS.LTASdB-inputLTASdB)/20);

% Derive equalization FIR filter
firLTAS = fir2(orderFIR,freqNorm,equalizeLTAS);


%% PERFORM LTAS EQUALIZATION
% 
% 
% Filter delay
delay = round(orderFIR/2);

% Zero-padding
padWithZeros = cat(1,input,zeros(delay,size(input,2)));

% FFT filtering (more efficient for long signals)
out = fftfilt(firLTAS,padWithZeros);

% Trim signal
out = out(delay+1:end,:);
