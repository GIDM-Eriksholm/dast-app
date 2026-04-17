%
% Helper function to call 'drawnow' in MATLAB or fflush(stdout) in OCTAVE
% after calling 'disp'
%
%               Copyright 2023 Daniel Berg, Oldenburg, Germany
%
function smp_disp(X)

disp(X);

if exist('fflush') > 0
    fflush(stdout);
else
    drawnow;
end

