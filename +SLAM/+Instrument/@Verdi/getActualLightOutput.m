% getActualLightOutput Query actual laser light output
%
% This method queries the measured light output (?LIGHT) in watts.
%    power = getActualLightOutput(object);
% Output "power" is the measured value as a numeric scalar.
%
% See also Verdi, getPowerSetpoint, setOutputPower
%
function power=getActualLightOutput(object)

response=communicate(object,'?LIGHT');
power=str2double(response);

fprintf('Actual light output: %.4f watts\n',power);

end