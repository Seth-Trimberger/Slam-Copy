% park Park system
%
% This method parks the system.
%    park(object);
% Subsequent motion commands are rejected as long as the device remains
% parked.
% 
% Parking also allows the system to be turned off without losing position
% information.  When a parked system is power cycled, its final previous
% position is recovered *after* it is unparked; values reported before this
% is done may be incorrect.  If the system is shut down without parking, it
% should always be homed before use.
%
% NOTE: homing automatically unparks the system.
% 
% See also Zaber, getParking, unpark
%
function park(object)

communicate(object,'/tools parking park');

end