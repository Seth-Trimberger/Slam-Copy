% delete Delete digitizer object
%
% This method deletes the digitizer object and the underlying device
% (TCP/IP, VISA, etc) connection.
%   delete(object);
% Explicit deletion is not usually required, but can be helpful in avoiding
% device conflicts.
%
% See also Digitizer
%
function delete(object)

try %#ok<TRYNC>
    delete(object.Device);
end

end