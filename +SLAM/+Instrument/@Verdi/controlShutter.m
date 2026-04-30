% controlShutter Open or close the laser shutter
%
% This method controls the Verdi laser mechanical shutter.
%    controlShutter(object,state);
% Input "state" must be 0 (close) or 1 (open).
%
% See also Verdi, getShutterStatus
%
function controlShutter(object,state)

if (nargin() < 2) || isempty(state)
    error('Verdi:controlShutter','shutter state must be specified (0=close, 1=open)');
end
if ~(isnumeric(state) && isscalar(state) && any(state == [0 1]))
    error('Verdi:controlShutter','shutter state must be 0 (close) or 1 (open)');
end

if state == 1
    fprintf('Opening the shutter\n');
else
    fprintf('Closing the shutter\n');
end

communicate(object,'SHUTTER=%d',state);
pause(0.4);

end