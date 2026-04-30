function [data,label,time]=read(object,bytes)

switch bytes
    case 1
        format='int8';
    case 2
        format='int16';
    otherwise
        error('ERROR: invalid number of read bytes');
end


data=[];
label={};
time=[];

available=communicate(object,':DATA:SOURCE:AVAILABLE?');
cols=numel(strfind(available,','))+1;
if strcmpi(available,'none')
    return
end

    function param=getParameter(varargin)
        buffer=communicate(object,varargin{:});
        buffer=strrep(buffer,';',' ');
        param=sscanf(buffer,'%g');
    end
communicate(object,...
    ':WFMOUTPRE:ENCDG BINARY; BYT_OR LSB; BYT_NR %d; BN_FMT RI',bytes);
points=getParameter('HORIZONTAL:MODE:RECORDLENGTH?');
communicate(object,'DATA:START 1; STOP %g',points);

label=cell(1,cols);
data=nan(points,cols);
k=1;
for n=1:numel(object.Channels)
    if contains(available,object.Channels{n},'IgnoreCase',true())
        label{k}=object.Channels{n};
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

if nargout() > 2
    param=getParameter('WFMOUTPRE:XINC?; XZERO?; PT_OFF?');
    xinc=param(1);
    xzero=param(2);
    pt_off=param(3);
    time=((1:points)-pt_off)*xinc+xzero;
    time=time(:);
end

end