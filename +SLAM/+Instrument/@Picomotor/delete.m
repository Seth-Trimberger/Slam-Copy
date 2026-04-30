% delete Delete Picomotor object
%
% This method turns off both motor drivers and closes the communication
% connection.
%    delete(object);
%
% See also Picomotor
%
function delete(object)

try %#ok<TRYNC>
    if ~isempty(object.Device)
        % turn off drivers before disconnecting (matches legacy shutdown)
        communicate(object,'MOF 1');
        pause(0.05);
        communicate(object,'MOF 2');
    end
end

try %#ok<TRYNC>
    delete(object.Device);
end

fprintf('Picomotor disconnected\n');

end