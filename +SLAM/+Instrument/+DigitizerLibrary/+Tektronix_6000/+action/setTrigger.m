% setTrigger Adjust trigger settings
%
% This function adjusts digitizer trigger settings.
%    setTrigger(object,source,level,slope);
% The inputs "source", "level", and "slope" are optional, defaulting to the
% current settings when empty/omitted.  
%     -The input "source" must be a character array or scalar string
%     matching a valid trigger sources, such as 'CH1' or 'AUXILARY'.
%     -The input "level" must be a finite numeric scalar, indicating the
%     trigger threshold in volts.
%     -The input "slope" must be a character array or scalar string
%     matching a valid trigger slope, such as 'RISE' or 'FALL'.
%
% See also getTrigger
%
function setTrigger(object,source,level,slope)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

% manage input
[sourceOld,levelOld,slopeOld]=object.Action.getTrigger();
Narg=nargin();

if (Narg < 2) || isempty(source)
    source=sourceOld;
else
    assert(ischar(source) || isStringScalar(source),...
        'ERROR: invalid trigger source');
    assert(any(strcmpi(source,object.Feature.Trigger.Sources)),...
        'ERROR: invalid trigger source');
end

if (Narg < 3) || isempty(level)
    level=levelOld;
else
    assert(isnumeric(level) && isscalar(level) && isfinite(level),...
        'ERROR: invalid trigger level');
end


if (Narg < 4) || isempty(slope)
    slope=slopeOld;
else
    assert(ischar(slope) || isStringScalar(slope),...
        'ERROR: invalid trigger slope');
    assert(any(strcmpi(slope,object.Feature.Trigger.Slopes)),...
        'ERROR: invalid trigger slope');
end

% send commands
communicate(object,':TRIGGER:A:MODE NORMAL; TYPE EDGE');

communicate(object,':TRIGGER:A:EDGE:SOURCE %s',source);
if contains(source,'CH','IgnoreCase',true())
    communicate(object,':TRIGGER:A:LEVEL:%s %g',source,level);
elseif strcmpi(source,'AUXILIARY')
    communicate(object,':TRIGGER:AUXLEVEL %g',level);
end

communicate(object,':TRIGGER:A:EDGE:SLOPE %s',slope);

end