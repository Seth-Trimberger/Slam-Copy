% connect Establish connection to the NI USB-6009 DAQ
%
% This *static* method opens a DAQ session and configures the digital
% output port for solenoid control.
%    daq = DAQUSB6009.connect(deviceName);
%    daq = DAQUSB6009.connect(deviceName,portName);
% Mandatory input "deviceName" specifies the NI device ID, e.g. 'Dev3'.
% Optional input "portName" defaults to 'port0'.
%
% All 8 lines on the port are added (port0/line0:7) because the
% USB-6009 DAQ Toolbox driver requires this — adding a subset of
% lines causes write() to silently fail with no error.
%
% Outputs are zeroed on connection (safety).
%
% See also DAQUSB6009, listDevices
%
function object=connect(deviceName,portName)

if (nargin() < 1) || isempty(deviceName)
    error('DAQUSB6009:connect','device name is required (e.g. ''Dev3'')');
end
if ~(ischar(deviceName) || isStringScalar(deviceName))
    error('DAQUSB6009:connect','device name must be a character array or string');
end
deviceName=char(deviceName);

if (nargin() < 2) || isempty(portName)
    portName='port0';
end
if ~(ischar(portName) || isStringScalar(portName))
    error('DAQUSB6009:connect','port name must be a character array or string');
end
portName=char(portName);

lineSpec=sprintf('%s/line0:7',portName);

try
    device=daq("ni");
    addoutput(device,deviceName,lineSpec,'Digital');
catch ME
    error('DAQUSB6009:connect','DAQ setup failed: %s',ME.message);
end

persistent constructor
if isempty(constructor)
    constructor=handy.generateCall('DAQUSB6009');
end
object=constructor(device,deviceName,portName);

% zero outputs on connect (safety)
writePattern(object,uint8(0));

fprintf('DAQUSB6009: connected on %s/%s\n',deviceName,portName);

end