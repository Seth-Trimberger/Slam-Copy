% controlEcho Enable or disable RS-232 echo
%
% This method controls the Verdi laser RS-232 echo setting.
%    controlEcho(object,state);
% Input "state" must be 0 (disable) or 1 (enable).
%
% Echo is automatically disabled during connect.  Disabling echo produces
% cleaner query responses for programmatic control.
%
% See also Verdi, connect
%
function controlEcho(object,state)

if (nargin() < 2) || isempty(state)
    error('Verdi:controlEcho','echo state must be specified (0=disable, 1=enable)');
end
if ~(isnumeric(state) && isscalar(state) && any(state == [0 1]))
    error('Verdi:controlEcho','echo state must be 0 (disable) or 1 (enable)');
end

if state == 0
    fprintf('Echo disabled\n');
else
    fprintf('Echo enabled\n');
end

communicate(object,'ECHO=%d',state);

end