function manage(MaxDig)

% manage input
MaxDigDefault=10;
if (nargin() < 1) || isempty(MaxDig)
    MaxDig=MaxDigDefault;
else
    assert(isnumeric(MaxDig) && isscalar(MaxDig) && (MaxDig >= 1),...
        'ERROR: invalid max number of digitizers');
    MaxDig=ceil(MaxDig);
end

persistent FontName
if isempty(FontName)
    FontName=get(groot(),'FixedWidthFontName');
end

cb=SLAM.Developer.ComponentBox();
setName(cb,'Manage digitizers')
setFont(cb,'',18);

label='Save file location:';
hLocation=addEdit(cb,[numel(label) 50]);
set(hLocation(1),'Text',label,'FontWeight','normal');
current=pwd();
set(hLocation(2),'Value',current,'UserData',current',...
    'ValueChangedFcn',@typeLocation);
    

label='Select';
hSelect=addButton(cb,numel(label));
set(hSelect,'Text',label,'ButtonPushedFcn',@selectLocation);

newRow(cb);
label={'' 'Address/alias' 'Base file name' 'Connected','Armed'};
width=nan(size(label));
for k=1:numel(label)
    if k == 1
        width(k)=6;
    elseif any(k == [2 3])
        width(k)=20;
    else
        width(k)=numel(label{k});
    end
end
hTable=addTable(cb,width,MaxDigDefault+1);
for k=1:numel(label)
    hTable(k).Text=label{k};
end
%set(hTable(4:5),'HorizontalAlignment','center');
hTable(end).ColumnEditable=[true() true() true() false() false()];
hTable(end).ColumnFormat={{'VISA' 'Socket'} 'char' 'char' 'char' 'char'};

data=cell(MaxDig,4);
for k=1:MaxDig
    data{k,1}='VISA';
    data{k,2}='';
    data{k,3}='';
    data{k,4}='';
    data{k,5}='';
end
set(hTable(end),'Data',data);

label={'Connect' 'Arm' 'Stop' 'Force'};
width=max(cellfun(@numel,label));
hDig=addButton(cb,width,numel(label));
for k=1:numel(label)
    hDig(k).Text=label{k};
end
set(hDig(1),'FontWeight','normal','ButtonPushedFcn',@makeConnections);
set(hDig(2),'ButtonPushedFcn',@digArm);
set(hDig(3),'ButtonPushedFcn',@digStop);
set(hDig(4),'ButtonPushedFcn',@digForce);
newRow(cb);

label='Arm with autosave';
hArm=addButton(cb,numel(label));
set(hArm,'Text',label,'FontWeight','normal','ButtonPushedFcn',@armSave);

label='Manual save';
hSave=addButton(cb,numel(label));
set(hSave,'Text',label,'ButtonPushedFcn',@manualSave);

% shared data and functions
data={};
object=[];

monitor=timer('ExecutionMode','fixedDelay','TimerFcn',@monitorArm);
    function monitorArm(varargin)
        data=get(hTable(end),'Data');
        count=0;
        out=invoke(object,'getState');
        for nn=1:numel(object)
            if strcmpi(out{nn}{1},'arm')
                data{nn,end}='yes';
                count=count+1;
            else
                data{nn,end}='';
            end
        end
        set(hTable(end),'Data',data);
        if count == 0
            stop(monitor);
        end
    end

% callbacks
    function typeLocation(varargin)
        new=get(hLocation(2),'Value');
        if isfolder(new)
            set(hLocation(2),'UserData',new);
        else
            old=get(hLocation(2),'UserData');
            set(hLocation(2),'Value',old);
        end
    end

    function selectLocation(varargin)
        current=get(hLocation(2),'Value');
        new=uigetdir(current,'Select location');
        if isnumeric(new)
            return
        end
        set(hLocation(2),'Value',new);
    end

    function makeConnections(varargin)
        delete(object);
        object=[];
        data=get(hTable(end),'Data');
        for nn=1:size(data,1)
            data{nn,4}='';
            data{nn,5}='';
        end
        set(hTable(end),'Data',data);
        for nn=1:size(data,1)
            resource=strtrim(data{nn,2});
            if isempty(resource)
                continue
            end
            try
                switch lower(data{nn,1})
                    case 'visa'
                        new=SLAM.Instrument.VisaDigitizer.connect(resource);
                    case 'socket'
                        new=SLAM.Instrument.TcpipDigitizer.connect(resource);
                end
                link(new);
            catch
                continue
            end
            data{nn,4}='yes';
            set(hTable(end),'Data',data);
            if isempty(object)
                object=new;
            else
                object=[object new]; %#ok<AGROW>
            end
        end
    end
    
    function digArm(varargin)
        invoke(object,'arm');
        start(monitor);
    end
    
    function digStop(varargin)
        invoke(object,'stop');
        monitorArm();
    end
    
    function digForce(varargin)
        invoke(object,'forceTrigger');
        monitorArm();
    end

    function armSave(varargin)
        location=get(hLocation(end),'Value');
        data=get(hTable(end),'Data');
        for nn=1:numel(object)
            file=strtrim(data{nn,3});
            if isempty(file)
                object(nn).Action.arm();
            else
                dest=fullfile(location,file);
                temp=fileparts(dest);
                if ~isfolder(temp)
                    mkdir(temp);
                end
                object(nn).Action.arm(dest);
            end
        end
        monitorArm();
    end

    function manualSave(varargin)
        location=get(hLocation(end),'Value');
        data=get(hTable(end),'Data');
        for nn=1:numel(object)
            file=strtrim(data{nn,3});
            if isempty(file)
                continue
            end
            dest=fullfile(location,file);
            temp=fileparts(dest);
            if ~isfolder(temp)
                mkdir(temp);
            end
            object(nn).Action.saveSignal(dest);
        end
    end
% finish up
fit(cb);
locate(cb);
show(cb);

end