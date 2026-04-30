% lock Lock out local control
% 
% This function locks out local control, disabling the touch screen and front
% panel buttons/knobs.
%    lock(object);
%
% See also unlock
%
function lock(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

communicate(object,'LOCK ALL');

end