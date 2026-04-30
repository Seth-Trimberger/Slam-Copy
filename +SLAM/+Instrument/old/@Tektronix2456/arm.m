% arm Start acquisition
%
% This method starts acquisition.
%    arm(object);
% New signals are recorded when the digitizer is triggered.
%
% See also Tektronix456, checkStatus, disarm, forceTrigger
% 
function arm(object,mode)

% manage input
if (nargin() < 2) || isempty(mode) || strcmpi(mode,'single')
    mode='single';
elseif strcmpi(mode,'run')
    mode='run';
elseif strcmpi(mode,'stop')
    mode='stop';
else
    error('ERROR: invalid arm mode')
end

% send commands
switch mode
    case 'single'
        communicate(object,'ACQUIRE:STOPAFTER SEQUENCE');
    case 'run'
        communicate(object,'ACQUIRE:STOPAFTER RUNSTOP');
    case 'stop'
        disarm(object);
        return
end
communicate(object,'ACQUIRE:STATE ON');

end