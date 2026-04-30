% setVelocity Set step velocity for a specific axis (VEL command)
%
% Matches C: sprintf(cmdStr,"VEL %d %d=%d\n", drive, axis, velocity)
%    setVelocity(object,drive,axis,velocity);
% Input "drive" must be 1 or 2.
% Input "axis" must be 0 or 1.
% Input "velocity" must be 0 to 2000 steps/sec.
%
% See also Picomotor, moveRelative
%
function setVelocity(object,drive,axis,velocity)

if (nargin() < 4)
    error('Picomotor:setVelocity','drive, axis, and velocity must be specified');
end
if ~(isnumeric(drive) && isscalar(drive) && any(drive == [1 2]))
    error('Picomotor:setVelocity','drive must be 1 or 2');
end
if ~(isnumeric(axis) && isscalar(axis) && any(axis == [0 1]))
    error('Picomotor:setVelocity','axis must be 0 or 1');
end
if ~(isnumeric(velocity) && isscalar(velocity) && velocity >= 0 && velocity <= 2000)
    error('Picomotor:setVelocity','velocity must be 0 to 2000 steps/sec');
end

communicate(object,sprintf('VEL %d %d=%d',drive,axis,round(velocity)));
fprintf('Velocity set to %d steps/sec for driver %d axis %d\n',round(velocity),drive,axis);

end