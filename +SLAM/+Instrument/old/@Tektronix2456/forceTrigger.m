% forceTrigger Force digitizer acquisition
%
% This method forces the digitizer to digitizer to acquire data with a
% manual trigger.
%   forceTrigger(object)
%
% See also Tektronix456, arm, checkStatus, disarm
%
function forceTrigger(object)

communicate(object,'FPANEL:PRESS FORCETRIG');

end