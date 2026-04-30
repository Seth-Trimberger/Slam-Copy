% turnOnDriver Power on a motor driver (MON command)
%
% Matches C: sprintf(cmdStr,"MON %d\n", drive)
%    turnOnDriver(object,drive);
% Input "drive" must be 1 or 2.
%
% See also Picomotor, turnOffDriver
%
function turnOnDriver(object,drive)

if (nargin() < 2) || isempty(drive)
    error('Picomotor:turnOnDriver','drive number must be specified (1 or 2)');
end
if ~(isnumeric(drive) && isscalar(drive) && any(drive == [1 2]))
    error('Picomotor:turnOnDriver','drive must be 1 or 2');
end

communicate(object,sprintf('MON %d',drive));
object.DriverOn(drive)=true;
fprintf('Motor driver %d is now ON\n',drive);

end