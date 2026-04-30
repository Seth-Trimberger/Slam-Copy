% writePattern Write an 8-bit pattern to the DAQ port (internal)
%
% This method converts a uint8 scalar into the 8-element row vector
% [line0 line1 ... line7] that the DAQ Toolbox write() function
% expects when all 8 lines are added.
%    writePattern(object,pattern);
%
% This is an internal helper — use setSolenoid, blockPZT, writeRaw,
% etc. for normal operation.
%
% See also DAQUSB6009, setSolenoid, writeRaw
%
function writePattern(object,pattern)

lineVector=bitget(pattern,1:8);
write(object.DAQDevice,lineVector);
object.CurrentBitPattern=uint8(pattern);

end