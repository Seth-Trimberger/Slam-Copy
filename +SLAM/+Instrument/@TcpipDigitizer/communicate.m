% communicate Send device commands
%
% This method sends SCPI commands to the digitizer's TCPIP server.  These
% commands can be explicit.
%    communicate(object,command);
% or built up from a format string with arguments.
%    communicate(object,format,arg1,arg2,...);
% Commands built from format-argument inputs use sprintf conventions.
%
% Query commands (which contain a '?' character) return character output.
%    response=communicate(object,query);
% Requesting a response for a non-query command generates a warning.
%
% NOTE: the device buffer is automatically cleared before new commands are
% sent.
%
% See also SLAM.Instrument.TcpipDigitizer, sprintf
% 
function varargout=communicate(object,varargin)

% error checking
assert(isscalar(object),...
    'ERROR: communication must be done one object at a time');
assert(isvalid(object.Device),'ERROR: invalid device');

% prepare command
if isempty(varargin)
    varargin{1}='*IDN?';
end

try
    command=sprintf(varargin{:});
catch 
    error('ERROR: invalid command string');
end
flush(object.Device);

% send command and deal with response
if contains(command,'?')
    response=writeread(object.Device,command);    
    response=char(strtrim(response));    
    varargout{1}=response;
else
    writeline(object.Device,command);
    if nargout() > 0
        warning('Non-query commands do not return output');
        varargout{1}='';
    end    
end

end