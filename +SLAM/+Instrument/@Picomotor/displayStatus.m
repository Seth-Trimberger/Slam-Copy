% displayStatus Print connection info and current motor state
%
%    displayStatus(object);
%
% See also Picomotor, getState
%
function displayStatus(object)

fprintf('\n--- Picomotor Status ---\n');
fprintf('Connection Type : %s\n',object.ConnectionType);
fprintf('Default Velocity: %d steps/sec\n',object.DefaultVelocity);
fprintf('Driver 1 On     : %d\n',object.DriverOn(1));
fprintf('Driver 2 On     : %d\n',object.DriverOn(2));
fprintf('Active Axis D1  : %d\n',object.ActiveAxis(1));
fprintf('Active Axis D2  : %d\n',object.ActiveAxis(2));
fprintf('Position D1A0   : %d steps\n',object.Position(1));
fprintf('Position D1A1   : %d steps\n',object.Position(2));
fprintf('Position D2A0   : %d steps\n',object.Position(3));
fprintf('Position D2A1   : %d steps\n',object.Position(4));
fprintf('------------------------\n\n');

end