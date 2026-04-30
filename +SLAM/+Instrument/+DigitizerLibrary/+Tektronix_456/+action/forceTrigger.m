% forceTrigger Manually trigger digitizer
%
% This function manually triggers an armed digitizer; it has no effect
% otherwise.
%    forceTrigger(object);
%
% See also arm, stop
%
function forceTrigger(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

stop(object.Timer);
communicate(object,':TRIGGER FORCE');

end