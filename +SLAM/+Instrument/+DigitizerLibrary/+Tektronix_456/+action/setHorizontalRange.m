% setHorizontalRange Set horizontal range
%
% This function sets the horizontal range.
%    setHorizontalRange(object,range);
% Mandatory input "range" must be a two-element [start stop] array of time
% values in seconds.  The values, which must be finite and distinct, are
% automatically sorted.
%
% NOTE: actual start/stop times may slightly differ from their requested
% values based on actual sample rate and number of points supported by the
% digitizer.  
%
% See also getHorizontalRange, getSampleRate, setSampleRate
%
function setHorizontalRange(object,range)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

% manage input
assert((nargin() > 1) && ~isempty(range),'ERROR: range must be specified');
assert(isnumeric(range) && (numel(range) == 2),'ERROR: invalid range');
range=sort(range);
delta=diff(range);
assert((delta > 0) && isfinite(delta),'ERROR: invalid range');

% send commands
communicate(object,':HORIZONTAL:MODE MANUAL');
duration=diff(range);
position=-range(1)/duration*100;

rate=object.Action.getSampleRate();
points=ceil(duration*rate);
communicate(object,':HORIZONTAL:MODE:RECORDLENGTH %.0f',points);
communicate(object,':HORIZONTAL:POSITION %g',position);

end