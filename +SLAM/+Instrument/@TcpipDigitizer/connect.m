% connect Establish TCP/IP connection
%
% This *static* method establishes a TCP/IP connection with the digitizer
%    object=TcpipDigitizer.connect(address,port);
% Mandatory input "address" specificies the TCP/IP address for the
% digitizers.  Optional input "port" indicates the host port number,
% defaulting to 5025.  The output "object" is a basic object that must be
% linked to a command library to become useful.
%
% See also TcpipDigitizer, link
%
function object=connect(address,port)

Narg=nargin();
assert((Narg >= 1) && ~isempty(address),...
    'ERROR: TCP/IP address must be specified');

if (Narg < 2) || isempty(port)
    port=5025;
end

try
   device=tcpclient(address,port);
catch ME
    throwAsCaller(ME);
end

persistent constructor
if isempty(constructor)
    constructor=handy.generateCall('TcpipDigitizer');
end
object=constructor(device);

end