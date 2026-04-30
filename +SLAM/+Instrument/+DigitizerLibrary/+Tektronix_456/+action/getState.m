% getState Get acquisition state
%
% This function gets the current acquisition state.
%   [acquire,complete]=getState(object);
% The output "acquire" is a character indicating whether acqusition is in
% the 'arm' or 'stop' state.  The output "complete" is logical true after a
% successful acqusition (arm/trigger sequence) and false otherwise.
% 
function [acquire,complete]=getState(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');

response=query(object,':ACQUIRE:STATE?');
if strcmp(response,'0')
    acquire='stop';
else
    acquire='arm';
end

response=query(object,':ACQUIRE:SEQUENCE:CURRENT?');
complete=logical(sscanf(response,'%g'));

end