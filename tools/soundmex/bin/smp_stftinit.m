%
% Intialisation file function for function smp_stft (short time fourier
%     transformation with overlapped add and zero padding) 
%
%               Copyright 2023 Daniel Berg, Oldenburg, Germany
%
% VERSION HISTORY:
% 2008:         first version
% 2014-11-04:   bugfixes 
%               - creating out_winddow only, if zeropadding at all!
% 2015-03-06:   renamed to smp_stftinit for GNU Octave compatibility 
% 2018-05-25:   addedd windowshift
%
% This script is used to initialize global data used by script stft.m It
% must be called with correct arguments before calling stft. Usage is shown
% in tutorial file t_07b_realtime_plugin_spec.m See also file smp_stft.m
function smp_stftinit(buffersize, fftlen, windowlen, channels, userfcn)

global stft_data;

% calculate buffersize needed in stft.m
if (buffersize < fftlen)
    buffersize = 2 * fftlen;
else
    buffersize = 2 * buffersize;
end

% check passed fftlen and windowlen
if (windowlen > fftlen)
    error('windowlen must not be larger than fftlen');
end
if (mod((fftlen - windowlen), 2) ~= 0)
    error('fftlen - windowlen must be a multiple of 2');
end

% calculate input and output window
% - input window is a hanning window
in_window       = repmat(0.5*(1-cos(2*pi*(0:windowlen-1)'/windowlen)), 1, channels);
% create out_window variable initialized with 0
out_window      = 0;
% if zeropadding used then  output window as stretched hanning window (ones in the middle)
if (windowlen < fftlen)
    out_wnd         = 0.5*(1-cos(2*pi*(0:(fftlen-windowlen)-1)'/(fftlen-windowlen)));
    out_window      = repmat([out_wnd(1:length(out_wnd)/2-1) ; ones(fftlen-length(out_wnd), 1) ; out_wnd(length(out_wnd)/2:end)], 1, channels);
end

% calculate total latency to preload the outputbuffer with corresponding
% number of zeros
latency = windowlen + (fftlen - windowlen)/2;

% create global data structure containing all static data
stft_data  = struct('fftbuf',       zeros(fftlen, channels), ...                % buffer used for fft and calculation on short time spectra
                    'overlaplen',   fftlen - windowlen/2, ...                   % total length of overlap
                    'overlapbuf',   zeros(fftlen - windowlen/2, channels), ...  % buffer used for storing overlapped data
                    'bufsize',      buffersize, ...                             % (outer) buffersize for input and output
                    'channels',     channels, ...                               % number of channels
                    'fftlen',       fftlen, ...                                 % fft length
                    'windowlen',    windowlen, ...                              % window length
                    'windowshift',  windowlen/2, ...                            % window shift, i.e. halp of windowlen
                    'zeropadding',  (fftlen - windowlen)/2, ...                 % numbers of zeros to pad
                    'userfcn',      userfcn, ...                                % user command to call on short time spectra
                    'in',           struct('data', zeros(buffersize, channels), 'pos', 1, 'window', in_window),  ...        % (outer) input buffer
                    'out',          struct('data', zeros(buffersize, channels), 'pos', latency, 'window', out_window) ...   % (outer) output buffer, preloaded with zeros
                );
