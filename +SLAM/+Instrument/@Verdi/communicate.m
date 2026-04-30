% communicate Send commands to the Verdi laser
%
% This method sends commands to the Verdi laser over the VISA connection.
% Commands can be explicit:
%    communicate(object,command);
% or built from a format string with arguments:
%    communicate(object,format,arg1,arg2,...);
%
% Query commands (containing '?') return the parsed response value as a
% character array.  The Verdi prompt prefix (e.g. 'Verdi V-10>') is
% automatically stripped from query responses.
%    response = communicate(object,query);
%
% Non-query commands use writeread to clear the response buffer.
% Requesting output from a non-query command generates a warning.
%
% NOTE: the device buffer is automatically flushed before new commands
% are sent to prevent stale data from interfering with responses.
%
% See also Verdi, connect
%
function varargout=communicate(object,varargin)

% error checking
if ~isscalar(object)
    error('Verdi:communicate','communication must be done one object at a time');
end
if ~isvalid(object.Device)
    error('Verdi:communicate','device connection is invalid or has been deleted');
end

% prepare command
if isempty(varargin)
    varargin{1}='?SV';
end

try
    command=sprintf(varargin{:});
catch
    error('Verdi:communicate','invalid command string');
end

% flush stale data from the buffer
try %#ok<TRYNC>
    flush(object.Device,'input');
    pause(0.05);
    flush(object.Device,'input');
end

% send command and deal with response
if contains(command,'?')
    response=writeread(object.Device,command);
    response=char(strtrim(response));
    % strip Verdi prompt prefix (e.g. 'Verdi V-10>value')
    if contains(response,'>')
        parts=split(response,'>');
        response=char(strtrim(parts(end)));
    end
    varargout{1}=response;
else
    writeread(object.Device,command);
    pause(0.1);
    if nargout() > 0
        warning('Non-query commands do not return output');
        varargout{1}='';
    end
end

end