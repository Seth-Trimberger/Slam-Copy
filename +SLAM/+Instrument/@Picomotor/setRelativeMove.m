% setRelativeMove Set relative move distance in steps (REL command)
%
% Matches C: sprintf(cmdStr,"REL %d=%d\n", drive, picoStep)
%    setRelativeMove(object,drive,steps);
% Input "drive" must be 1 or 2.
% Input "steps" is a signed integer (negative = reverse direction).
%
% See also Picomotor, executeMove, moveRelative
%
function setRelativeMove(object,drive,steps)

if (nargin() < 3)
    error('Picomotor:setRelativeMove','drive and steps must be specified');
end
if ~(isnumeric(drive) && isscalar(drive) && any(drive == [1 2]))
    error('Picomotor:setRelativeMove','drive must be 1 or 2');
end
if ~(isnumeric(steps) && isscalar(steps))
    error('Picomotor:setRelativeMove','steps must be a numeric scalar');
end

communicate(object,sprintf('REL %d=%d',drive,round(steps)));

end