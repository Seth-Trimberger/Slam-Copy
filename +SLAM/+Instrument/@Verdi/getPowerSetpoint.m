% getPowerSetpoint Query laser power setpoint
%
% This method queries the commanded power setpoint (?SP) in watts.
%    power = getPowerSetpoint(object);
% Output "power" is the setpoint value as a numeric scalar.
%
% See also Verdi, setOutputPower, getActualLightOutput
%
function power=getPowerSetpoint(object)

response=communicate(object,'?SP');
power=str2double(response);

fprintf('Power setpoint: %.4f watts\n',power);

end