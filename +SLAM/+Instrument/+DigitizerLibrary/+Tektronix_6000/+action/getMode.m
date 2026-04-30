% getMode Read acquisition mode
% 
% This function reads the digitizer acquisition mode.
%   [mode,count]=getMode(object);
% The output "mode" indicates the operating mode.  The output "count"
% indicates the number of averages used in AVERAGE mode; this value is
% meaningless in other modes.
%
% See also setMode
% 
function [mode,count]=getMode(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');

mode=query(object,':ACQUIRE:MODE?');

temp=query(object,':ACQUIRE:NUMAVG?');
count=sscanf(temp,'%d');

end