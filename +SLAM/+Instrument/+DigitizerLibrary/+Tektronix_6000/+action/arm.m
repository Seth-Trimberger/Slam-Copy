% Arm Arm digitizer for single acquisition
%
% This function arms the digitizer for a single acquisition.
%    arm(object);
% 
% Passing a second argument:
%    arm(object,name);
% arms the digitizer with automatic saving to the base file "name".
% 
% See also stop
%
function arm(object,autosave)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

% manage input
if (nargin() < 2) || isempty(autosave)
    autosave='';
else
    if isstring(autosave)
        autosave=char(autosave);
    end
    assert(ischar(autosave),'ERROR: invalid autosave file name');
end


% send commands
stop(object.Timer);

communicate(object,':ACQUIRE:STOPAFTER SEQUENCE');
communicate(object,':ACQUIRE:STATE ON');
if strcmpi(object.Verbose,'on')
    fprintf('"%s" armed at %s\n',object.Name,datetime('now'));
end

object.Timer.TimerFcn=@checkStatus;
start(object.Timer);
    function checkStatus(varargin)
        [acquire,complete]=object.Action.getState();
        if strcmpi(acquire,'arm')
            return
        elseif ~complete
            if strcmpi(object.Verbose,'on')
                fprintf('"%s" stopped\n',object.Name);
            end
        else
            if strcmpi(object.Verbose,'on')
                fprintf('"%s" triggered\n',object.Name);
            end
            if ~isempty(autosave)
                object.Action.saveSignal(autosave);
                fprintf('"%s" files saved to "%s"\n',object.Name,autosave);
            end            
        end
        stop(object.Timer);        
    end
end