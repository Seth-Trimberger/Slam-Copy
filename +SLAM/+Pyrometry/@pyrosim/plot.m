% plot Plot pyrometry calculations
%
% This method plots pyrometry calculations in a new figure.
%    plot(object);
% Additional inputs may be used to control axis scaling.
%   plot(object,hscale,vscale);
% Optional inputs "hscale" and "vscale" control the horizontal and vertical
% axis, respectively.  Supported values include 'linear' (default) and
% 'log'.
%
% Requesting an output:
%    fig=plot(object,...);
% returns the graphic handle for the created figure.
%
% See also pyrosim, calculate, configure
% 
function varargout=plot(object,hscale,vscale)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(hscale)
    hscale='linear';
else
    assert(any(strcmpi(hscale,{'linear' 'log'})),...
        'ERROR: invalid horizontal scaling');
    hscale=lower(hscale);
end

if (Narg < 3) || isempty(vscale)
    vscale='linear';
else
    assert(any(strcmpi(vscale,{'linear' 'log'})),...
        'ERROR: invalid vertical scaling');
    vscale=lower(vscale);
end

% generate plot tabs
[data,param]=calculate(object);

name=sprintf('%s plot',object.Name);
fig=uifigure('HandleVisibility','on',...
    'Toolbar','figure','MenuBar','none',...
    'Name',name','NumberTitle','on','IntegerHandle','on');

hg=uitabgroup(fig,'Units','normalized','Position',[0 0 1 1]);
tablabel={'Power' 'Photons' 'Signal'};
label={'Power (W)' 'Photon flux (1/s)' 'Signal (V)'};
for n=1:numel(label)
    ht=uitab(hg,'Title',tablabel{n});
    ha=uiaxes(ht,'Units','normalized','Position',[0 0 1 1]);
    plot(ha,data(:,1),data(:,n+1));
    xlabel(ha,'Temperature (K)');
    ylabel(ha,label{n});
    set(ha,'XScale',hscale,'YScale',vscale);
end

% generate parameter tab
field={'Emissivity' 'Relay' 'Response' 'Diameter' 'Angle' 'Range' 'Points'};
unit={'' '' 'V/W' 'mm' 'deg' 'um' ''};
N=numel(field);
message=cell(N,1);
for n=1:N
    if isempty(unit{n})
        message{n}=sprintf('   %s = ',field{n});
    else
        message{n}=sprintf('   %s (%s) = ',field{n},unit{n});
    end
    value=param.(field{n});
    if isnumeric(value)
       format=repmat('%g ',[1 numel(value)]);
       value=sprintf(format,value);
    end
    message{n}=[message{n} value];
end
message(2:end+1)=message;
message{1}=sprintf('Calculation parameters (%s):',datetime('now'));

ht=uitab(hg,'Title','Parameters');
ha=uiaxes(ht,'Units','normalized','InnerPosition',[0 0 1 1]);
axis(ha,'off');
text(ha,0,1,message,'VerticalAlignment','top');  
disableDefaultInteractivity(ha)
ha.Toolbar.Visible='off';

% manage output
if nargout() > 0
    varargout{1}=fig;
end


end