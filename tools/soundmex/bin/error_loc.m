% 
%             Helper function for examples of SoundMexPro
%               Copyright 2023 Daniel Berg, Oldenburg, Germany
%
% Simple function printing an error location from passed dbstack

function error_location = error_loc(dbstack_input)
error_location = [' (file ' dbstack_input.name ', line ' num2str(dbstack_input.line) ')'];