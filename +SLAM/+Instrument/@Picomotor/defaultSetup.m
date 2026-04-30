% defaultSetup Initialize controller to default state
%
% This method replicates PicoDefaultSetup from TCPio.c, sending the
% same 8-command initialization sequence:
%    MON 1, CHL 1=0, VEL 1 0=100, VEL 1 1=100
%    MON 2, CHL 2=0, VEL 2 0=100, VEL 2 1=100
%
%    defaultSetup(object);
%
% See also Picomotor, connect
%
function defaultSetup(object)

fprintf('Running Picomotor default setup\n');

vel=object.DefaultVelocity;

commands={...
    'MON 1',                   ...
    'CHL 1=0',                 ...
    sprintf('VEL 1 0=%d',vel), ...
    sprintf('VEL 1 1=%d',vel), ...
    'MON 2',                   ...
    'CHL 2=0',                 ...
    sprintf('VEL 2 0=%d',vel), ...
    sprintf('VEL 2 1=%d',vel)  ...
};

for n=1:numel(commands)
    communicate(object,commands{n});
end

object.DriverOn=[true true];
object.ActiveAxis=[0 0];

fprintf('Picomotor default setup complete\n');

end