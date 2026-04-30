% readSignal Read analog signals
%
% This function reads analog signals from the digitizer.
%    [data,time,label]=readSignal(object,bytes);
% Optional input "bytes" indicates the number of bytes transmitted per
% sample point.  Valid choices are 1 (8 bits) or 2 (16 bits), defaulting to
% the latter when this argument is empty/omitted.  The output "data" is a
% numeric MxN array of M sample points over N active channels.  The output
% "time" is an Mx1 array of time locations for each sample.  The output
% "label" is a cellstr array indicating which channel is stored in the
% columns of "data".
%
% Calling the function with no output:
%    readSignal(object,bytes);
% plots the signals in a new figure.
%
% NOTE: only active channels with available data are read by this function.
% An error is generated when no signals are available.  
%
% See also saveSignal
%
function varargout=readSignal(object,bytes)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');
communicate(object,':HEADER ON; VERBOSE ON');

available=query(object,':DATA:SOURCE:AVAILABLE?');
assert(~strcmpi(available,'none'),'ERROR: no data available');

% manage input
Narg=nargin();
if (Narg < 2) || isempty(bytes) || (bytes == 2)
    format='int16';
    bytes=2;
elseif bytes == 1
    format='int8';
    bytes=1;
else
    error('ERROR: invalid number of read bytes');
end

% send commands
cols=numel(strfind(available,','))+1;
    function param=getParameter(varargin)
        buffer=communicate(object,varargin{:});
        param=[];
        while ~isempty(buffer)
            [~,~,~,next]=sscanf(buffer,'%s',1);
            buffer=buffer(next:end);
            [param(end+1),~,~,next]=sscanf(buffer,'%g',1); %#ok<AGROW>
            buffer=buffer(next:end);
        end
    end
communicate(object,...
    ':WFMOUTPRE:ENCDG BINARY; BYT_OR LSB; BYT_NR %d; BN_FMT RI',bytes);
points=getParameter('HORIZONTAL:MODE:RECORDLENGTH?');
communicate(object,'DATA:START 1; STOP %g',points);

label=cell(1,cols);
data=nan(points,cols);
k=1;
channels=object.Feature.Channels;
for n=1:numel(channels)
    if contains(available,channels{n},'IgnoreCase',true())
        label{k}=object.Feature.Channels{n};
        communicate(object,':DATA:SOURCE %s',label{k});
        param=getParameter('WFMOUTPRE:YMULT?; YOFF?; YZERO?');
        slope=param(1);
        u0=param(2);
        y0=param(3);
        writeline(object.Device,':CURVE?');
        raw=readbinblock(object.Device,format);
        readline(object.Device); % remove termination character
        raw=single(raw);
        data(:,k)=y0+slope*(raw-u0);
        k=k+1;
    end
end

param=getParameter('WFMOUTPRE:XINC?; XZERO?; PT_OFF?');
xinc=param(1);
xzero=param(2);
pt_off=param(3);
time=((0:points-1)-pt_off)*xinc+xzero;
time=time(:);

% manage output
if nargout() > 0
    varargout{1}=data;
    varargout{2}=time;
    varargout{3}=label;
    return
end

figure();
plot(time,data);
xlabel('Time (s)');
ylabel('Signal (V)');
legend(label,'Location','best');

end