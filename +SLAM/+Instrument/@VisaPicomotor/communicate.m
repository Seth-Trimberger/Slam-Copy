% communicate Send commands to Picomotor via VISA serial
%
% This method sends commands to the Picomotor controller over VISA.
%    communicate(object,command);
% The device buffer is flushed after each command to clear any response
% data (the 8742 does not respond to most commands, but some produce
% unsolicited output).
%
% See also VisaPicomotor, Picomotor
%
function communicate(object,command)

if ~isscalar(object)
    error('VisaPicomotor:communicate','communication must be done one object at a time');
end
if ~isvalid(object.Device)
    error('VisaPicomotor:communicate','device connection is invalid or has been deleted');
end

if (nargin() < 2) || isempty(command)
    error('VisaPicomotor:communicate','command string must be specified');
end
command=char(command);

try
    writeline(object.Device,command);
    pause(0.05);
    flush(object.Device);
catch ME
    fprintf('Error sending command "%s": %s\n',command,ME.message);
end

end