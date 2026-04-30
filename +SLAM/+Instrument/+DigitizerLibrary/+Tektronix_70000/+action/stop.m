% stop Stop digitizer acquisition
%
% This function stops digitizer acquisition.
%    stop(object);
%
% See also arm
%
function stop(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

communicate(object,':ACQUIRE:STATE OFF');

stop(object.Timer);
if strcmpi(object.Verbose,'on')
    fprintf('"%s" stopped\n',object.Name);
end

end