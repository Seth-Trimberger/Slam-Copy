% communicate Send/receive digitizer messages
%
% This method sends and receives digitizer messages.  Commands are sent
% using a format specification with optional arguments:
%    communicate(object,format,arg1,arg2,...);
% following sprintf conventions.  Messages containing a question mark (?)
% follow the same input convention but return an output argument.
%    response=communicate(object,format,arg1,arg2,...);
% Requesting an output for a non-query message generates a warning.  An
% error is generated if no response is received before the device timeout
% elapses.
%
% The default message is the standard SCPI command '*IDN?' when this
% message is called without input.
%    response=communicate(object).
%
% See also Tektronix456, sprintf
%
function varargout=communicate(object,varargin)

if nargin() == 1
    varargin{1}='*IDN?';
end

writeline(object.Device,'*CLS');
try
    command=sprintf(varargin{:});
catch
    error('ERROR: invalid command syntax');
end
writeline(object.Device,command);

% manage output
if contains(command,'?')
    t=0;
    while t < object.Device.Timeout
        response=readline(object.Device);
        response=char(strtrim(response));
        if isempty(response)
            pause(object.Delay);
            t=t+object.Delay;
            continue
        end
        break
    end    
    assert(~isempty(response),...
        'ERROR: device timeout before response received');
    varargout{1}=response;
else
    if nargout() > 0
        warning('Non-query commands do not return output');
        varargout{1}='';
    end    
end

end