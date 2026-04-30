% setPosition Set position
%
% This method sets device, normally specified by a numeric value.
%    setPosition(object,value);
%    setPosition(object,value,'absolute');
% The input "value" indicates the absolute position (in steps) with respect
% to home state.  Relative changes from the current state can also be
% requested.
%    setPosition(object,value,'position');
% 
% Two special positions can be requested by name.
%    setPosition(object,'min');
%    setPosition(object,'max');
% These positions are the nearest and furthest positions from home,
% respectively.  The minimum position is equivalant to the home position,
% i.e. the following call:
%    setPosition(object,'home');
% has the same effect.
%
% Requesting an output:
%    success=setPosition(object,...);
% returns a logical value indicating if the command is valid (true) or
% invalid (false).
%
% See also Zaber, getPosition, stop
%
function varargout=setPosition(object,value,mode)

assert(nargin > 1,'ERROR: no position specified');

if (nargin() < 3) || isempty(mode) || ...
        any(strcmpi(mode,{'abs' 'absolute'}))
    mode='abs';
elseif any(strcmpi(mode,{'rel' 'relative'}))
    mode='rel';
else
    error('ERROR: invalid position mode');
end

if any(strcmpi(value,{'home' 'min'}))
    [~,report]=communicate(object,'/home');
    object.LastPositionRequest='min';
elseif strcmp(value,'max')
    [~,report]=communicate(object,'/move max');
    object.LastPositionRequest='max';
else
    assert(isnumeric(value),'ERROR: invalid position')
    [~,report]=communicate(object,'/move %s %g',mode,value);
    object.LastPositionRequest=sprintf('%.0f %s',value,mode);
end

% manage output
if nargout > 0
    varargout{1}=true;
    if strcmp(report.Data,'BADDATA')
        varargout{1}=false;
    end
end

end