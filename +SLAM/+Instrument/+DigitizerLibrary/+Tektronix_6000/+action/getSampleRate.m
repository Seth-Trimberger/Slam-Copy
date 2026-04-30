% getSampleRate Get current sample rate
%
% This function gets the current sample rate.
%    value=getSampleRate(object);
% The ouput "value" is sample rate in Hertz.
% 
% See also getHorizontalRange, getInterpolationRatio, setSampleRate
%
function rate=getSampleRate(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');

response=query(object,':HORIZONTAL:MAIN:SAMPLERATE?');
rate=sscanf(response,'%g',1);

end