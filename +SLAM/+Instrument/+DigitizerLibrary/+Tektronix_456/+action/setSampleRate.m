% setSampleRate Set sample rate
%
% This function sets the sample rate.
%    setSampleRate(object,value);
% Mandatory input "value" must be a finite number > 0.  When this value is
% passed to the digitzer, the actual sample rate may be somewhat different
% thatn requested based on the digitizer's capabilities.
%
% NOTE: requested a higher sampling rate than the digitizer supports may
% activate interpolation.
%
% See also getInterpolationRatio, getSampleRate, setHorizontalRange
%
function setSampleRate(object,rate)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

% manage input
assert((nargin() > 1) && ~isempty(rate),...
    'ERROR: sample rate must be specified');
assert(isnumeric(rate) && isscalar(rate) && (rate > 0),...
    'ERROR: invalid sample rate');

% send commands
communicate(object,':HORIZONTAL:MODE MANUAL');
communicate(object,':HORIZONTAL:MODE:SAMPLERATE %g',rate);

end