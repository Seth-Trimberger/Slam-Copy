% configure Interactive parameter control and plotting
%
% This method incorporates parameter control and plotting in an interactive
% dialog box.  The command:
%    calculate(object);
% creates a new dialog box unless there is an existing figure associated
% with the object; if so, that previously generated figure is made visible.
% All parameter changes made in the dialog are immediately applied to the
% object.  Changes made outside of the dialog must be loaded using "Refresh
% parameters" under "Menu".
%
% NOTE: All editable fields in this dialog box expect numeric values.  Text
% file sources (emissivity, relay, and/or response) are not currently
% supported in interactive mode.
%
% See also pyrosim, calculate, plot
%
function configure(object,fontsize)

% look for previous figure
fig=findall(groot(),'Tag','pyrosim');
for n=1:numel(fig)
    previous=getappdata(fig(n),'object');
    if previous == object
        fprintf('Using existing component box\n');
        figure(fig(n));
        return
    end
end

% manage input
Narg=nargin();
if (Narg < 2) || isempty(fontsize)
    fontsize=18;
else
    assert(isnumeric(fontsize) && isscalar(fontsize) && (fontsize > 0),...
        'ERROR: invalid font size');   
end

% set up GUI
cb=SLAM.Developer.ComponentBox();
setFont(cb,'',fontsize);
setLabelPosition(cb,'left');
LabelWidth=5;
EditWidth=5;

hTemperature=addEdit(cb,[LabelWidth EditWidth]);
hTemperature(1).Text='$T$ (K): ';
hTemperature(1).Interpreter='latex';
set(hTemperature,'Tooltip',...
    'Source temperature (numeric array and/or colon/linspace/logspace statement)');
newRow(cb);

hEmissivity=addEdit(cb,[LabelWidth EditWidth]);
hEmissivity(1).Text='$\epsilon$ (-): ';
hEmissivity(1).Interpreter='latex';
set(hEmissivity,'Tooltip','Source emissivity (number from 0 to 1)');

hRelay=addEdit(cb,[LabelWidth EditWidth]);
hRelay(1).Text='$\eta$ (-): ';
hRelay(1).Interpreter='latex';
set(hRelay,'Tooltip','Relay efficiency (number from 0 to 1)');

hResponse=addEdit(cb,[LabelWidth EditWidth]);
hResponse(1).Text='$\rho$ (V/W): ';
hResponse(1).Interpreter='latex';
set(hResponse,'Tooltip','Detector response (number >= 0)');
newRow(cb);

hDiameter=addEdit(cb,[LabelWidth EditWidth]);
hDiameter(1).Text='$d$ (mm): ';
hDiameter(1).Interpreter='latex';
set(hDiameter,'Tooltip','Collection diameter (number >= 0)');

hAngle=addEdit(cb,[LabelWidth EditWidth]);
hAngle(1).Text='$\theta$ (deg): ';
hAngle(1).Interpreter='latex';
set(hAngle,'Tooltip','Maximum collection angle (number from 0 to 90)');
newRow(cb);

hRange=addEdit(cb,[LabelWidth EditWidth]);
hRange(1).Text='$\lambda_b$ (um): ';
hRange(1).Interpreter='latex';
set(hRange,'Tooltip','Spectral integration range [min max]');

hPoints=addEdit(cb,[LabelWidth EditWidth]);
hPoints(1).Text='N (-): ';
hPoints(1).Interpreter='latex';
set(hPoints,'Tooltip','Number of integration points');
newRow(cb);

hData=addTable(cb,repmat(10,[1 4]),15);
hData(1).Text=' Temperature (K)';
hData(2).Text=' Power (W)';
hData(3).Text=' Photons (1/s)';
hData(4).Text=' Signal (V)';

stretchRight(cb,hTemperature(2),hResponse(2));
stretchRight(cb,hRange(2),hAngle(2));

fit(cb);
[parent,component]=combine(cb);
fig=ancestor(parent(1),'figure');
movegui(fig,'center');
fig.Name=sprintf('%s configuration',object.Name);
fig.Tag='pyrosim';
setappdata(fig,'object',object);

tg=uitabgroup(parent(2),'Units','normalized','Position',[0 0 1 1]);
tablabel={'Power' 'Photons' 'Signal'};
label={'Power (W)' 'Photon flux (1/s)' 'Signal (V)'};
for n=1:numel(label)
    ht=uitab(tg,'Title',tablabel{n});
    ha=uiaxes(ht,'Units','normalized','Position',[0 0 1 1],...
        'FontSize',fontsize);
    xlabel(ha,'Temperature (K)');
    ylabel(ha,label{n});
    hl=line(ha,'Color','k','XData',[],'YData',[]);
    if n == 1
        hLine=repmat(hl,size(label));
    else
        hLine(n)=hl;
    end
end

delete(cb);

% make GUI useful
    function readTemperature(varargin)
        value=str2num(component(2).Value,Evaluation='restricted'); %#ok<ST2NM>
        if ~isempty(value)
            try
                object.Temperature=value;            
            catch
                value=[];
            end
        end
        if isempty(value)
            component(2).Value=sprintf('%.6g ',object.Temperature);
        end
        update();
    end
component(2).ValueChangedFcn=@readTemperature;

    function readEmissivity(varargin)
        value=sscanf(component(4).Value,'%g',1);
        if ~isempty(value)
            try %#ok<TRYNC>
                object.Emissivity=value;
            end
        end
        component(4).Value=sprintf('%g',object.Emissivity);
        update();
    end
component(4).ValueChangedFcn=@readEmissivity;

    function readRelay(varargin)
        value=sscanf(component(6).Value,'%g',1);        
        if ~isempty(value)
            try %#ok<TRYNC>
                object.Relay=value;
            end
        end
        component(6).Value=sprintf('%g',object.Relay);
        update();
    end
component(6).ValueChangedFcn=@readRelay;

    function readResponse(varargin)
        value=sscanf(component(8).Value,'%g',1);        
        if ~isempty(value)
            try %#ok<TRYNC>
                object.Response=value;
            end
        end
        component(8).Value=sprintf('%g',object.Response);
        update();
    end
component(8).ValueChangedFcn=@readResponse;

function readDiameter(varargin)
        value=sscanf(component(10).Value,'%g',1);        
        if ~isempty(value)
            try %#ok<TRYNC>
                object.Diameter=value;
            end
        end
        component(10).Value=sprintf('%g',object.Diameter);
        update();
end
component(10).ValueChangedFcn=@readDiameter;

    function readAngle(varargin)
        value=sscanf(component(12).Value,'%g',1);        
        if ~isempty(value)
            try %#ok<TRYNC>
                object.Angle=value;
            end
        end
        component(12).Value=sprintf('%g',object.Angle);
        update();
    end
component(12).ValueChangedFcn=@readAngle;

    function readRange(varargin)
        value=sscanf(component(14).Value,'%g',2);             
        if ~isempty(value)
            try %#ok<TRYNC>
                value=reshape(value,1,[]);
                object.Range=value;
            end
        end
        component(14).Value=sprintf('%g %g',object.Range);
        update();
    end
component(14).ValueChangedFcn=@readRange;

    function readPoints(varargin)
        value=sscanf(component(16).Value,'%g',1);        
        if ~isempty(value)
            try %#ok<TRYNC>
                object.Points=value;
            end
        end
        component(16).Value=sprintf('%g',object.Points);
        update();
    end
component(16).ValueChangedFcn=@readPoints;

    function update(varargin)
        data=calculate(object);
        tb=cell(size(data));
        for kk=1:numel(data)
            tb{kk}=sprintf('%g',data(kk));
        end
        component(end).Data=tb;      
        for nn=1:3
            set(hLine(nn),'XData',data(:,1),'YData',data(:,nn+1));
        end       
        if size(data,1) < 10
            set(hLine,'Marker','o');
        else
            set(hLine,'Marker','none');
        end        
    end
update();

% add menu items
hm=uimenu(fig,'Text','Menu');
uimenu(hm,'Text','Refresh parameters','MenuSelectedFcn',@refresh)
    function refresh(varargin)
        set(component(2:2:16),'Value','');
        readTemperature();
        readEmissivity();
        readRelay();
        readResponse();
        readDiameter();
        readAngle();
        readRange();
        readPoints();
    end
refresh();

hScaleH=uimenu(hm,'Text','Horizontal scaling');
uimenu(hScaleH,'Text','Linear','MenuSelectedFcn',@scaleH,'Checked','on');
uimenu(hScaleH,'Text','Log','MenuSelectedFcn',@scaleH)
    function scaleH(varargin)
        set(hScaleH.Children,'Checked','off');
        src=varargin{1};
        src.Checked='on';
        for nn=1:numel(hLine)
            set(hLine(nn).Parent,'XScale',lower(src.Text));
        end        
    end

hScaleV=uimenu(hm,'Text','Vertical scaling');
uimenu(hScaleV,'Text','Linear','MenuSelectedFcn',@scaleV,'Checked','on');
uimenu(hScaleV,'Text','Log','MenuSelectedFcn',@scaleV)
    function scaleV(varargin)
        set(hScaleV.Children,'Checked','off');
        src=varargin{1};
        src.Checked='on';
        for nn=1:numel(hLine)
            set(hLine(nn).Parent,'Yscale',lower(src.Text));
        end        
    end

uimenu(hm,'Text','Export data','MenuSelectedFcn',@exportData);
    function exportData(varargin)
        commandwindow();
        name=input('Export variable name: ','s');
        if isempty(name)
            fprintf('Export cancelled\n');
            figure(fig);
            return
        elseif ~isvarname(name)            
            name=matlab.lang.makeValidName(name);
            fprintf('Name changed to "%s"',name);
        end
        data=calculate(object);
        assignin('base',name,data);
        fprintf('Export complete\n');
        figure(fig);
    end

uimenu(hm,'Text','Exit','Separator','on','MenuSelectedFcn',@done);
    function done(varargin)
        delete(fig);
    end

end