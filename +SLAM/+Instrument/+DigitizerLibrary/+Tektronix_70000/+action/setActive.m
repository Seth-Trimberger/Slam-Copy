% setActive Set active channels
%
% This function sets the active digitizer channels.
%    setActive(object,channels);
% Optional input "channels" can be an integer or logical array.  All
% channels are made active when this input is empty/omitted. Activating
% specific channels automatically deactivates all others.  For example:
%    setActive(object,[1 3]);
% activates channels 1 and 2 while deactivating channel 2 and channels 4+
% (model dependent).  Logical arrays must use placeholders between active
% and inactive channels, e.g.:
%    setActive(object,[true false true]);
% has the same effect as above, with automatic deactivation for missing
% entries (channels 4+).
%
% NOTE: all integer and logical channel requests must be consitent with the
% number of available channels.  Requests outside this range will generate
% an error.
%
% See also getActive
%
function setActive(object,channels)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

% manage input
valid=object.Feature.Channels;
if (nargin() < 2) || isempty(channels)
    channels=valid;
elseif isnumeric(channels) || islogical(channels)
    try
        channels=valid(channels);
    catch
        error('ERROR: invalid channel request');
    end
end

for n=1:numel(valid)
    if any(strcmpi(valid{n},channels))
        communicate(object,':SELECT:%s ON',valid{n});
    else
        communicate(object,':SELECT:%s OFF',valid{n});
    end
end

end