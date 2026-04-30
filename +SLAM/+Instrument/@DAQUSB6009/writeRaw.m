% writeRaw Write an arbitrary 8-bit value directly to the port
%
% This method provides direct legacy-compatible access matching the
% original C DAQdigOut() function.
%    writeRaw(object,value);
% Input "value" must be an integer in [0, 255].
%
% Legacy equivalents:
%    writeRaw(daq, 0)   ->  DAQdigOut(panel, 0)  ->  all off
%    writeRaw(daq, 1)   ->  DAQdigOut(panel, 1)  ->  PZT blocked
%    writeRaw(daq, 2)   ->  DAQdigOut(panel, 2)  ->  Etalon blocked
%    writeRaw(daq, 3)   ->  DAQdigOut(panel, 3)  ->  both blocked
%
% See also DAQUSB6009, setSolenoid
%
function writeRaw(object,value)

if ~object.IsConnected
    error('DAQUSB6009:writeRaw','DAQ not connected');
end

if (nargin() < 2) || isempty(value)
    error('DAQUSB6009:writeRaw','raw value must be specified');
end
if ~(isnumeric(value) && isscalar(value) && value >= 0 && value <= 255 && mod(value,1) == 0)
    error('DAQUSB6009:writeRaw','raw value must be an integer in [0, 255]');
end

writePattern(object,uint8(value));

end