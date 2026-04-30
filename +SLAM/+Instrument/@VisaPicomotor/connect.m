% connect Establish VISA serial connection to Picomotor
%
% This *static* method creates a VISA serial connection to the 8742.
%    pico = VisaPicomotor.connect(resource);
% Mandatory input "resource" specifies a VISA address such as
% 'ASRL4::INSTR'.
%
% Default setup is run automatically after connection.
%
% See also VisaPicomotor, Picomotor
%
function object=connect(resource)

if (nargin() < 1) || isempty(resource)
    error('VisaPicomotor:connect','VISA resource must be specified');
end
if ~(ischar(resource) || isStringScalar(resource))
    error('VisaPicomotor:connect','invalid VISA resource');
end
resource=char(resource);

try
    device=visadev(resource);
catch ME
    throwAsCaller(ME);
end

device.BaudRate=19200;
device.DataBits=8;
device.StopBits=1;
device.Parity='none';
device.FlowControl='none';
device.Timeout=5;
configureTerminator(device,'LF');

pause(0.2);
flush(device);

persistent constructor
if isempty(constructor)
    constructor=handy.generateCall('VisaPicomotor');
end
object=constructor(device);

defaultSetup(object);

fprintf('Picomotor connected via VISA at %s\n',resource);

end