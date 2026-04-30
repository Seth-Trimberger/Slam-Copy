% getStatus Get current status
%
% This method queries the current sytem status.
%    value=getStatus(object);
% The output "value" is 'BUSY' when the system is moving and 'IDLE'
% otherwise.
%
% See also Zaber, wait4idle
% 
function [value,report]=getStatus(object)

[~,report]=communicate(object,'/');

value=report.DeviceStatus;

end