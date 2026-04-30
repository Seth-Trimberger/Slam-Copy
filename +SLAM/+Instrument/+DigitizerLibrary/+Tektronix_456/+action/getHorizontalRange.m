% getHorizontalRange Get horizontal range
%
% This function gets the current horizontal range.
%    [value,points]=getHorizontalRange(object);
% The output "value" is a two-element [start stop] aray of time values in
% units of seconds.  The output "points" is the number of points needed to
% support that horizontal range for the current sample rate.
%
% See also getSampleRate, setHorizontalRange, setSampleRate
%
function [range,points]=getHorizontalRange(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');

response=query(object,':HORIZONTAL:ACQDURATION?');
duration=sscanf(response,'%g',1);

response=query(object,':HORIZONTAL:POSITION?');
position=sscanf(response,'%g',1);

left=-duration*position/100;
right=+duration*(1-position/100);
range=[left right];

response=query(object,':HORIZONTAL:DELAY:TIME?');
delay=sscanf(response,'%g',1);
range=range+delay;

if nargout() < 2
    return
end
response=query(object,':HORIZONTAL:MODE:RECORDLENGTH?');
points=sscanf(response,'%g',1);

end