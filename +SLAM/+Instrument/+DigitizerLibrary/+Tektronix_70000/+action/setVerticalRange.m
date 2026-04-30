% setVerticalRange Adjust vertical ranges
%
% This function adjusts vertical range for the analog channels.
%    setVerticalRange(object,range);
% Mandatory input "range" must be a two-column array of numbers indicating
% min/max voltage levels.  Single-row values are shared across all
% channels.  Mixed ranges are specified starting from channel 1, retaining
% current values for missing entries.  For example:
%    setVerticalRange(object,[-1 1; -2 2;]);
% modifies channels 1-2 while leaving channels 3+ unchanged.
%
% NOTE: actual range may differ slightly from the request based on how
% finely the digitizer is able to adjust the vertical scale.  The vertical
% position selected for the requested range account for vertical offset. 
%
% See also getVerticalOffset, getVerticalRange
%
function setVerticalRange(object,range)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

% manage input
assert(nargin() > 1,'ERROR: vertical range must be specified');
assert(isnumeric(range) && ismatrix(range) && all(isfinite(range(:))),...
    'ERROR: invalid vertical range');

channels=object.Feature.Channels;
N=numel(channels);
previous=object.Action.getVerticalRange();
if numel(range) == 2
    range=reshape(range,[1 2]);
    range=repmat(range,[N 1]);
else
    [rows,cols]=size(range);
    assert(cols == 2,'ERROR: range array must have two columns');
    if rows < N
        previous(1:rows,:)=range;
        range=previous;
    else
        range=range(1:N,:);
    end
end

% send commands
divisions=object.Feature.Divisions;
offset=object.Action.getVerticalOffset();
for n=1:N
    value=sort(range(n,:));
    scale=(value(2)-value(1))/divisions(2);
    position=-(value(1)-offset(n))/scale-divisions(2)/2;
    communicate(object,':%s:POSITION %g; SCALE %g',...
        channels{n},position,scale);
end

end