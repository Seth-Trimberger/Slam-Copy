% unlock Restore local control
% 
% This function restores local control, enabling the touch screen and front
% panel buttons/knobs. 
%    unlock(object);
%
% See also lock
%
function unlock(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

communicate(object,'LOCK NONE');

end