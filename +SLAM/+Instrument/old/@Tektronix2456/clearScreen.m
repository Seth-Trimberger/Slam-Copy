% clearScreen Clear digitizer screen
%
% This method clears the digitizer screen and all acquired signals.
%    clearScreen(object);
%
% See also Tektronix456, arm, checkStatus, forceTrigger
% 
function clearScreen(object)

communicate(object,'CLEAR');

end