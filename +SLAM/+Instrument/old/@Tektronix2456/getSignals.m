% UNDER CONSTRUCTION
%
% See also Tektronix456
% 
function varargout=getSignals(object)

report=checkStatus(object);
channel=report.Data;
N=numel(channel);
assert(~isempty(report.Data),'ERROR: no data available');

% 16-bit signed integers
communicate(object,...
    ':WFMOUTPRE:ENCDG BINARY; BYT_OR LSB; BYT_NR 2; BN_FMT RI');
    function array=ask4(command)
        buffer=communicate(object,command);
        buffer=strrep(buffer,';',' ');
        array=sscanf(buffer,'%g');    
    end

label=cell(1,N);
for n=1:N
    communicate(object,':DATA:SOURCE CH%d',channel(n));
    %disp(communicate(object,':DATA:SOURCE?'));
    if n == 1
        points=ask4('HORIZONTAL:MODE:RECORDLENGTH?');
        communicate(object,'DATA:POINTS:START 1; STOP %g',points);
        param=ask4('WFMOUTPRE:NR_PT?; XINC?; XZERO?; PT_OFF?');
        points=param(1);
        xinc=param(2);
        xzero=param(3);
        pt_off=param(4);
        time=((1:points)-pt_off)*xinc+xzero;
        time=time(:);
        data=nan(points,N);
    end
    param=ask4('WFMOUTPRE:YMULT?; YOFF?; YZERO?');
    slope=param(1);
    u0=param(2);
    y0=param(3);
    writeline(object.Device,':CURVE?');
    raw=readbinblock(object.Device,'int16');    
    raw=single(raw);
    data(:,n)=y0+slope*(raw-u0);    
    label{n}=sprintf('Channel %d',channel(n));
end

% manage output
if nargout() > 0
    varargout{1}=data;
    varargout{2}=time;
    varargout{3}=label;
    return
end

figure()
plot(time,data);
legend(label,'Location','best');

end