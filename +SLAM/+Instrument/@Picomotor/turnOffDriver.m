% turnOffDriver Power off a motor driver (MOF command)
%
% Matches C: sprintf(cmdStr,"MOF %d\n", drive)
%    turnOffDriver(object,drive);
% Input "drive" must be 1 or 2.
%
% See also Picomotor, turnOnDriver
%
function turnOffDriver(object,drive)

if (nargin() < 2) || isempty(drive)
    error('Picomotor:turnOffDriver','drive number must be specified (1 or 2)');
end
if ~(isnumeric(drive) && isscalar(drive) && any(drive == [1 2]))
    error('Picomotor:turnOffDriver','drive must be 1 or 2');
end

if ~object.DriverOn(drive)
    fprintf('Motor driver %d is already off\n',drive);
    return
end

communicate(object,sprintf('MOF %d',drive));
object.DriverOn(drive)=false;
fprintf('Motor driver %d is now OFF\n',drive);

end