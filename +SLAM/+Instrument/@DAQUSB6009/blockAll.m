% blockAll Block both interferometer legs simultaneously
%
% Equivalent to legacy: DAQdigOut(panel, 3)
%    blockAll(object);
%
% See also DAQUSB6009, unblockAll
%
function blockAll(object)

if ~object.IsConnected
    error('DAQUSB6009:blockAll','DAQ not connected');
end

newPattern=bitor(object.BIT_PZT,object.BIT_ETALON);
writePattern(object,newPattern);
fprintf('DAQUSB6009: both legs blocked (output = %d)\n',newPattern);

end