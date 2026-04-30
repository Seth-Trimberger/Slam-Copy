% setMode Adjust acquistion mode
%
% This function adjusts the digitizer acquistion mode.
%    setMode(object,mode,count)
% Optional input "mode" indicates the desired mode, which can be 'SAMPLE',
% 'HIRES', or 'AVERAGE'; the current mode is used when argument is
% empty/omitted.  Optional input "count" indicates the number of averages
% used in "AVERAGE" mode, defaulting to the current setting.
%
% NOTE: the number of averages can be changed in any mode, but this value
% has no effect outside of 'AVERAGE' mode.
%
% See also getMode
%
function setMode(object,mode,count)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

% manage input
[pMode,pCount]=object.Action.getMode();
Narg=nargin();
if (Narg < 2) || isempty(mode)
    mode=pMode;
else
    if isStringScalar(mode)
        mode=char(mode);
    end
    assert(ischar(mode),'ERROR: invalid mode');
    assert(any(strcmpi(mode,object.Feature.Modes)),...
        'ERROR: "%s" is not a supported mode');
end

if (Narg < 3) || isempty(count)
    count=pCount;
else
    assert(isnumeric(count) && isscalar(count) && (count >= 1),...
        'ERROR: invalid average count');
    count=ceil(count);
end

communicate(object,':ACQUIRE:MODE %s',mode);
communicate(object,':ACQUIRE:NUMAVG %d',count);

end