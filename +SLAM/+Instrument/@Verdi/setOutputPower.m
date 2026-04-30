% setOutputPower Set laser output power
%
% This method sets the Verdi laser output power in watts.
%    setOutputPower(object,power);
% Input "power" must be between 0.0001 and 10.9999 watts in nn.nnnn
% format (4 decimal places maximum).
%
% See also Verdi, getPowerSetpoint, getActualLightOutput
%
function setOutputPower(object,power)

if (nargin() < 2) || isempty(power)
    error('Verdi:setOutputPower','power value must be specified');
end
if ~(isnumeric(power) && isscalar(power))
    error('Verdi:setOutputPower','power must be a numeric scalar');
end
if power < 0.0001 || power > 10.9999
    error('Verdi:setOutputPower','power must be in range 0.0001 to 10.9999 watts');
end

rounded=round(power,4);
if abs(power - rounded) > eps
    error('Verdi:setOutputPower','power must have 4 or fewer decimal places (nn.nnnn format)');
end

fprintf('Setting output power to %.4f watts\n',power);
communicate(object,'P=%.4f',power);
pause(0.4);

end