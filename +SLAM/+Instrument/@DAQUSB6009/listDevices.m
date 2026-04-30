% listDevices Print all NI-DAQ devices visible to MATLAB
%
% This *static* method lists available NI-DAQ devices.
%    DAQUSB6009.listDevices();
%
% See also DAQUSB6009, connect
%
function listDevices()

try
    devices=daqlist("ni");
catch ME
    error('DAQUSB6009:listDevices','failed to list devices: %s',ME.message);
end

if isempty(devices)
    fprintf('No NI-DAQ devices found.\n');
else
    fprintf('Available NI-DAQ devices:\n');
    disp(devices);
end

end