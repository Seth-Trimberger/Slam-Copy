% moveRelative Full move sequence: select axis, set distance, execute
%
% Replicates the PicoMove() sequence from AlignCtrl.c:
%    1. MON (if driver not already on)
%    2. CHL - select axis
%    3. REL - set relative move distance
%    4. GO  - execute
%
% Also updates the cumulative Position array.
%    moveRelative(object,drive,axis,steps);
% Input "drive" must be 1 or 2.
% Input "axis" must be 0 or 1.
% Input "steps" is a signed integer (negative = reverse direction).
%
% See also Picomotor, selectAxis, setRelativeMove, executeMove
%
function moveRelative(object,drive,axis,steps)

if (nargin() < 4)
    error('Picomotor:moveRelative','drive, axis, and steps must be specified');
end
if ~(isnumeric(drive) && isscalar(drive) && any(drive == [1 2]))
    error('Picomotor:moveRelative','drive must be 1 or 2');
end
if ~(isnumeric(axis) && isscalar(axis) && any(axis == [0 1]))
    error('Picomotor:moveRelative','axis must be 0 or 1');
end
if ~(isnumeric(steps) && isscalar(steps))
    error('Picomotor:moveRelative','steps must be a numeric scalar');
end

steps=round(steps);

% turn on driver if not already on (matches C driverOn[] check)
if ~object.DriverOn(drive)
    turnOnDriver(object,drive);
    pause(0.1);
end

selectAxis(object,drive,axis);
pause(0.1);
setRelativeMove(object,drive,steps);
pause(0.1);
executeMove(object,drive);

% update cumulative position
% axisIndex: D1A0=1, D1A1=2, D2A0=3, D2A1=4
axisIndex=2*(drive-1)+axis+1;
object.Position(axisIndex)=object.Position(axisIndex)+steps;

fprintf('Move complete. Position[D%dA%d] = %d steps\n',drive,axis,object.Position(axisIndex));

end