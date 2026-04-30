% delete Delete DAQUSB6009 object
%
% This method zeros all outputs (safety) and releases the DAQ session.
%    delete(object);
%
% See also DAQUSB6009
%
function delete(object)

try %#ok<TRYNC>
    if object.IsConnected
        writePattern(object,uint8(0));
    end
end

try %#ok<TRYNC>
    if ~isempty(object.DAQDevice)
        delete(object.DAQDevice);
    end
end

object.IsConnected=false;
fprintf('DAQUSB6009: disconnected\n');

end