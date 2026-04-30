% setVerticalOffset Adjust vertical offsets
%
% This function adjusts vertical offset for the analog channels.
%    setVerticalOffset(object,offset);
% Optional input "offset" indicates the vertical offset in volts,
% defaulting to 0 when empty/omitted.  Scalar offsets are shared across all
% channels.  Mixed offset values are defined starting at channel 1,
% retaining current values for missing entries.  For example:
%    setVerticalOffset(object,[1 1]);
% adjusts the offset values for channels 1-2 while leaving channels 3+
% unchanged.  Extra offsets (beyond the number of available channels) are
% ignored.
%
% See also getVerticalOffset
%
function setVerticalOffset(object,offset)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

% manage input
previous=object.Action.getVerticalOffset();
N=numel(previous);
if (nargin() < 2) || isempty(offset)
    offset=zeros(size(previous));
else
    assert(isnumeric(offset) && all(isfinite(offset)),...
        'ERROR: invalid vertical offset');
    if isscalar(offset)
        offset=repmat(offset,size(previous));
    elseif numel(offset) < N
        N1=numel(offset);
        previous(1:N1)=offset;
        offset=previous;
    else
        offset=offset(1:N);
    end
end

% send commands
channels=object.Feature.Channels;
for n=1:numel(channels)
    communicate(object,':%s:OFFSET %g',channels{n},offset(n));
end

end