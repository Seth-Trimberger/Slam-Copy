% getInterpolationRatio Get interpolation ratio
%
% This function gets the sampling interpolation ratio.
%    value=getInterpolationRatio(object);
% The output "value" is a number >= 1.  Values greater than one indicate
% that the digitizer is interpolating data to provide signals at a higher
% sample rate the the device supports.  In practice, one usually wants the
% value to be 1, meaning that interpolation is not in use.
%
% See also getSampleRate, setSampleRate
%
function value=getInterpolationRatio(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');

response=query(object,'HORizontal:MAIn:INTERPRatio?');
value=sscanf(response,'%g',1);

end