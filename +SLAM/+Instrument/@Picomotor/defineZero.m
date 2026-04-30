% defineZero Reset all position counters to zero
%
% Matches C: DefineZeroCB - sets picoPos[0..3] = 0
% This is a software-only reset; no command is sent to hardware.
%    defineZero(object);
%
% See also Picomotor, moveRelative
%
function defineZero(object)

object.Position=[0 0 0 0];
fprintf('Picomotor position counters reset to zero\n');

end