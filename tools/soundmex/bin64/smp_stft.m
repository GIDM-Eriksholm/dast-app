%
% Implementation of block-wise short time fourier transformation
%       with overlapped add and zero padding (stft)
%
%               Copyright 2023 Daniel Berg, Oldenburg, Germany
%
% VERSION HISTORY:
% 2008:         first version
% 2014-11-04:   bugfixes 
%               - calculating number of FFTs per loop bugfix
%               - apply out window only if zero padding is done at all
% 2015-03-06:   renamed to smp_stft for GNU Octave compatibility 
% 2018-05-25:   bugfix copying output buffer 
%
% This script implements a block-wise short time fourier transformation
% with overlapped add and zero padding. The function/script stftinit.m
% must be called with correct arguments before calling stft. Usage is shown
% in tutorial file t_07b_realtime_plugin_spec.m 
%
% This stft uses a fixed overlap of 0.5. You may extend it for using other
% overlaps (take care of scaling that will be necessary then!).
% 
% IMPORTANT NOTE: this script is optimized to avoid unnecessary duplication
% and resizing of data to get maximum performance in a real time
% environment. When changing/extending this script take care not to create
% local data arrays or copies of arrays.
function y = smp_stft(x);

global stft_data;

%--------------------------------------------------------------------------
% - check input data
 if (stft_data.channels ~= size(x,2))
    error('invalid number of channels passed');
end
data_length = size(x,1);

% check available space in input buffer
if (data_length > (stft_data.bufsize - stft_data.in.pos + 1))
    error('too many sample passed');
end

%--------------------------------------------------------------------------
% - write new data to input buffer
%(stft_data.in.pos + data_length-1)
stft_data.in.data(stft_data.in.pos : (stft_data.in.pos + data_length-1), :) = x;
% adjust position in input buffer
stft_data.in.pos = stft_data.in.pos + data_length;
%--------------------------------------------------------------------------


% - do  FFT-loop
% calculate number of calls to be done with inner blocksize (windowlen)
numffts = 0;
if (stft_data.in.pos > stft_data.windowlen)
    numffts = fix((stft_data.in.pos - stft_data.windowlen)/stft_data.windowshift) + 1; % NOTE /2 is the overlap!
end
numsamples = numffts*stft_data.windowshift;

% check, if enough space in out buffer
if ((stft_data.bufsize - stft_data.out.pos + 1) < numsamples)
    error('not enough space in output buffer');
end

read_pos = 1;
for i = 1 : numffts
    % read one buffer from input to fft buffer
    % - write leading and trailing zeros
    stft_data.fftbuf(1:stft_data.zeropadding,:) = 0;
    stft_data.fftbuf(end-stft_data.zeropadding+1:end,:) = 0;
    % - write data to fft buffer
    stft_data.fftbuf(stft_data.zeropadding+1:stft_data.zeropadding + stft_data.windowlen,:) = stft_data.in.data(read_pos:read_pos+stft_data.windowlen-1,:) .*stft_data.in.window;
    % adjust read position by half(!) windowlen (overlap)
    read_pos = read_pos + stft_data.windowshift;
    

    % do fft
    stft_data.fftbuf = fft(stft_data.fftbuf);
    
    
    % call user script
    feval(stft_data.userfcn);
    %user_test;

    % do ifft
    stft_data.fftbuf = real(ifft(stft_data.fftbuf));    
    
    % apply back window (if zwropadding at all!)
    if (stft_data.zeropadding > 0)
        stft_data.fftbuf = stft_data.fftbuf.*stft_data.out.window;
    end
    % do overlapped add
    stft_data.fftbuf(1:stft_data.overlaplen,:) = stft_data.fftbuf(1:stft_data.overlaplen,:) + stft_data.overlapbuf;
    % copy new data to overlap buffer for next run
    stft_data.overlapbuf = stft_data.fftbuf(end-stft_data.overlaplen+1:end,:);

    % write data to output buffer
    stft_data.out.data(stft_data.out.pos : stft_data.out.pos + stft_data.windowshift-1,:) = stft_data.fftbuf(1:stft_data.windowshift,:);
    stft_data.out.pos = stft_data.out.pos + stft_data.windowshift;
end

%--------------------------------------------------------------------------
% - copy remaining input data (if any) to beginning of input buffer
in_remain = stft_data.in.pos - numsamples - 1;
if (in_remain > 0)
    stft_data.in.data(1 : in_remain,:) = stft_data.in.data(numsamples+1:numsamples+in_remain,:);
end
% adjust position of input buffer
stft_data.in.pos = in_remain + 1;

%--------------------------------------------------------------------------
% - write data to argout (i.e. y)
if ((stft_data.out.pos - 1) < data_length)
    % not enough samples: prepend zeros. To avoid realloc first write 
    % zeroes only!
    y = zeros(data_length, stft_data.channels);

    % then write available data (if any)
    if (stft_data.out.pos > 1)
        write_pos = data_length - stft_data.out.pos + 2;
        y(write_pos : write_pos + stft_data.out.pos-2, :) = stft_data.out.data(1 : stft_data.out.pos-1,:);
   end
    % now buffer is empty in every case!
    stft_data.out.pos = 1;
else
    % simply copy data
    y = stft_data.out.data(1 : data_length,:);
    out_remain = stft_data.out.pos - data_length - 1;
    % move remaining data to beginning of buffer
    if (out_remain > 0)
        stft_data.out.data(1 : out_remain,:) = stft_data.out.data(data_length+1:data_length+out_remain,:);
    end
    % adjust space
    stft_data.out.pos = out_remain + 1;
end
