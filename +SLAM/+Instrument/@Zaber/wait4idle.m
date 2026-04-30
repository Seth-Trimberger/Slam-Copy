% wait4idle Wait until sytem is idle
%
% This methods waits until the system status is idle, halting executation
% of any other MATLAB comments.
%    wait4idle(object,timeout);
% Optional input "timeout" specifies the maximum wait time in seconds; the
% default value is 60 s.
%
% See also Zaber, getStatus
%
function wait4idle(object,timeout)

if (nargin() < 2) || isempty(timeout)
    timeout=60;
else
    assert(isnumeric(timeout) && isscalar(time) && (timout > 0),...
        'ERROR: invalid time out')
end

increment=1;
while timeout > 0
    current=getStatus(object);
    if strcmpi(current,'IDLE')
        break
    end
    pause(increment);
    timeout=timeout-increment;
end

end