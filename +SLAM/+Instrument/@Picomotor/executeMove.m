% executeMove Trigger the move (GO command)
%
% Matches C: sprintf(cmdStr,"GO %d\n", drive)
%    executeMove(object,drive);
% Input "drive" must be 1 or 2.
% Must be preceded by selectAxis and setRelativeMove.
%
% See also Picomotor, moveRelative, setRelativeMove
%
function executeMove(object,drive)

if (nargin() < 2) || isempty(drive)
    error('Picomotor:executeMove','drive number must be specified (1 or 2)');
end
if ~(isnumeric(drive) && isscalar(drive) && any(drive == [1 2]))
    error('Picomotor:executeMove','drive must be 1 or 2');
end

communicate(object,sprintf('GO %d',drive));

end