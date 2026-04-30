% disarm Stop acquisition
%
% This method stop acquisition without triggering the digitizer.
%    disarm(object);
% No new sigals are recorded.
%
% See also Tektronix456, arm, checkStatus, forceTrigger
% 
function disarm(object)

communicate(object,'ACQUIRE:STATE STOP')

end