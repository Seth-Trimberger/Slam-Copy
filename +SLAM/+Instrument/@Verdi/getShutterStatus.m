% getShutterStatus Query laser shutter status
%
% This method queries the current shutter state (?S).
%    status = getShutterStatus(object);
% Output "status" is 0 (closed), 1 (open), or -1 (unknown/error).
%
% See also Verdi, controlShutter
%
function status=getShutterStatus(object)

response=communicate(object,'?S');
status=str2double(response);

if status == 0
    fprintf('Shutter is closed\n');
elseif status == 1
    fprintf('Shutter is open\n');
else
    fprintf('Error: laser did not return a valid shutter status\n');
    status=-1;
end

end