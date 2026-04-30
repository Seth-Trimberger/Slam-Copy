% connect Establish TCP/IP connection to Picomotor
%
% This *static* method creates a TCP/IP connection to the 8742.
%    pico = TcpipPicomotor.connect(ipAddress);
%    pico = TcpipPicomotor.connect(ipAddress,port);
% Mandatory input "ipAddress" is the controller's IP address string.
% Optional input "port" defaults to 23 (Telnet, matching legacy system).
%
% Default setup is run automatically after connection.
%
% See also TcpipPicomotor, Picomotor
%
function object=connect(ipAddress,port)

if (nargin() < 1) || isempty(ipAddress)
    error('TcpipPicomotor:connect','IP address must be specified');
end
if ~(ischar(ipAddress) || isStringScalar(ipAddress))
    error('TcpipPicomotor:connect','invalid IP address');
end
ipAddress=char(ipAddress);

if (nargin() < 2) || isempty(port)
    port=23;
end
if ~(isnumeric(port) && isscalar(port) && port >= 1 && port <= 65535)
    error('TcpipPicomotor:connect','port must be 1-65535');
end

try
    device=tcpclient(ipAddress,port);
    device.Timeout=5;
catch ME
    throwAsCaller(ME);
end

pause(0.2);
if device.NumBytesAvailable > 0
    flush(device);
end

persistent constructor
if isempty(constructor)
    constructor=handy.generateCall('TcpipPicomotor');
end
object=constructor(device);

defaultSetup(object);

fprintf('Picomotor connected via TCP/IP at %s:%d\n',ipAddress,port);

end