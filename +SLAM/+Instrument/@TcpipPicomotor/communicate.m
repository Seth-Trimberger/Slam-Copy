% communicate Send commands to Picomotor via TCP/IP
%
% This method sends commands to the Picomotor controller over TCP/IP.
%    communicate(object,command);
% The device buffer is flushed after each command to clear any response
% data.  Uses NumBytesAvailable check before flushing (supported by
% tcpclient but not visadev).
%
% See also TcpipPicomotor, Picomotor
%
function communicate(object,command)

if ~isscalar(object)
    error('TcpipPicomotor:communicate','communication must be done one object at a time');
end
if ~isvalid(object.Device)
    error('TcpipPicomotor:communicate','device connection is invalid or has been deleted');
end

if (nargin() < 2) || isempty(command)
    error('TcpipPicomotor:communicate','command string must be specified');
end
command=char(command);

try
    writeline(object.Device,command);
    pause(0.05);
    if object.Device.NumBytesAvailable > 0
        flush(object.Device);
    end
catch ME
    fprintf('Error sending command "%s": %s\n',command,ME.message);
end

end