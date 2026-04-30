% communicate Send command and receive reply
%
% This methods sends a message to the device.  Commands may be self
% contained:
%    communicate(object,message);
% or constructed from format/argument inputs.
%    communicate(object,format,arg1,arg2,...);
% The latter uses the sprintf function to combine the format string with
% passed arguments.
%
% Device replies are returned by request only.
%    [raw,report]=communicate(object,...);
% The output "raw" contains the as received reply.  The output "report" is
% a structure where reply information has been parsed and interpreted.
%
% NOTE: previous replies are automatically cleared each time a message is
% sent to the device.  This behavior can be changed by setting the
% AutoFlush property to 'off'.
%
% See also Zaber, sprintf
%
function varargout=communicate(object,message,varargin)

% send message
delay=0;
if nargin() > 1
    try
        message=sprintf(message,varargin{:});
    catch ME
        throwAsCaller(ME);
    end
    if strcmpi(object.AutoFlush,'on')
        flush(object.Connection);
    end
    writeline(object.Connection,message);
    delay=0.05;
end

% receive message
if nargout == 0
    return
end

pause(delay);
raw='';
report='';
while object.Connection.BytesAvailable > 0
    buffer=char(readline(object.Connection));
    current=parseReply(buffer);
    if isempty(report)
        report=current;
    else
        report(n+1)=current;
    end
    raw=[raw buffer]; %#ok<AGROW>
end
varargout{1}=raw;
varargout{2}=report;

end

function report=parseReply(message)

switch message(1)
    case '@'
        report.Type='reply';
    case '#'
        report.Type='info';
    case '!'
        report.Type='alert';
end
message=message(2:end);

report.DeviceAddress=message(1:2);
message=message(4:end);

report.AxisNumber=message(1);
message=message(3:end);

report.MessageID=message(1:2);
message=message(4:end);

report.DeviceStatus=message(1:4);
message=message(6:end);

report.WarningFlag=message(1:2);
message=message(4:end);

report.Data=strtrim(message);

end