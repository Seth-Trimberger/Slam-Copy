% selectAxis Set the active channel/axis for a driver (CHL command)
%
% Matches C: sprintf(cmdStr,"CHL %d=%d\n", drive, axis)
%    selectAxis(object,drive,axis);
% Input "drive" must be 1 or 2.
% Input "axis" must be 0 or 1.
%
% See also Picomotor, moveRelative
%
function selectAxis(object,drive,axis)

if (nargin() < 3)
    error('Picomotor:selectAxis','drive and axis must be specified');
end
if ~(isnumeric(drive) && isscalar(drive) && any(drive == [1 2]))
    error('Picomotor:selectAxis','drive must be 1 or 2');
end
if ~(isnumeric(axis) && isscalar(axis) && any(axis == [0 1]))
    error('Picomotor:selectAxis','axis must be 0 or 1');
end

communicate(object,sprintf('CHL %d=%d',drive,axis));
object.ActiveAxis(drive)=axis;
fprintf('Axis %d selected on driver %d\n',axis,drive);

end