% unblockAll Clear all outputs — both legs unblocked
%
% Equivalent to legacy: DAQdigOut(panel, 0)
%    unblockAll(object);
%
% See also DAQUSB6009, blockAll
%
function unblockAll(object)

if ~object.IsConnected
    error('DAQUSB6009:unblockAll','DAQ not connected');
end

writePattern(object,uint8(0));
fprintf('DAQUSB6009: all legs unblocked (output = 0)\n');

end