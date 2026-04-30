% stopMove Abort an in-progress move (ST command)
%
%    stopMove(object);          % stop all drivers
%    stopMove(object,drive);    % stop specific driver (1 or 2)
%
% See also Picomotor, moveRelative, executeMove
%
function stopMove(object,drive)

if (nargin() < 2) || isempty(drive)
    fprintf('Stopping all drivers\n');
    communicate(object,'ST');
else
    if ~(isnumeric(drive) && isscalar(drive) && any(drive == [1 2]))
        error('Picomotor:stopMove','drive must be 1 or 2');
    end
    fprintf('Stopping driver %d\n',drive);
    communicate(object,sprintf('ST %d',drive));
end

end