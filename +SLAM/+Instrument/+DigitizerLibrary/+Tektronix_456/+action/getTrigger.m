% getTrigger Get trigger settings
% 
% This function adjusts digitizer trigger settings.
%    [source,level,slope]=getTrigger(object);
% The output "source" indicates where triggers are received, e.g. 'CH1' or
% 'AUXILARY', as a character array.  The output "level" is the numerical
% threshold for triggering in volts, e.g. 1.  The output 'slope' indicates
% signal direction for triggering, e.g. 'RISE', as a character array.
%
% See also setTrigger
%
function [source,level,slope]=getTrigger(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');

% send commands
response=query(object,':TRIGGER:A:EDGE:SOURCE?');
source=response;
if contains(source,'CH','IgnoreCase',true())
    response=query(object,':TRIGGER:A:LEVEL:%s?',source);
elseif strcmpi(source,'AUXILIARY')
    response=query(object,':TRIGGER:AUXLEVEL?');
else
    response='nan';
end
level=sscanf(response,'%g',1);

slope=query(object,':TRIGGER:A:EDGE:SLOPE?');

end