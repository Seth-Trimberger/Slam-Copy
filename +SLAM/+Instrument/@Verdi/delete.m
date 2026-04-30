% delete Delete Verdi laser object
%
% This method deletes the Verdi laser object and the underlying VISA
% device connection.
%    delete(object);
% Explicit deletion is not usually required, but can be helpful in avoiding
% device conflicts.
%
% See also Verdi
%
function delete(object)

try %#ok<TRYNC>
    delete(object.Device);
end

end