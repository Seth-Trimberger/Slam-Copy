% manage Picomotor alignment control panel
%
% This *static* method launches a GUI panel for controlling the New Focus
% Picomotor 8742 controller.
%    Picomotor.manage();
%
% Replicates the legacy AlignCtrl panel (AlignCtrl.c / AlignCtrl.h).
% Supports both TCP/IP and VISA serial connections.
%
% See also Picomotor, VisaPicomotor, TcpipPicomotor
%
function manage()

cb=SLAM.Developer.ComponentBox();
setName(cb,'Picomotor Alignment Control');
setFont(cb,'Consolas');

% shared state (closure variables)
pico=[];
connected=false;

% resolve package-safe connect functions
persistent visaConnectFcn tcpConnectFcn
if isempty(visaConnectFcn)
    location=fileparts(fileparts(mfilename("fullpath")));
    package=extractAfter(location,'+');
    package=strrep(package,[filesep '+'],'.');
    visaConnectFcn=str2func([package '.VisaPicomotor.connect']);
    tcpConnectFcn=str2func([package '.TcpipPicomotor.connect']);
end

%% ---- Connection ----
hConnLabel=addMessage(cb,40,1);
hConnLabel.Text='=== Connection ===';
hConnLabel.FontWeight='bold';

newRow(cb);
hConnType=addDropdown(cb,10);
hConnType(1).Text='Type:';
hConnType(2).Items={'TCP/IP','VISA'};
hConnType(2).Value='TCP/IP';
hConnType(2).ValueChangedFcn=@connectionTypeChanged;

newRow(cb);
hIPAddr=addEdit(cb,20);
hIPAddr(1).Text='IP Address:';
hIPAddr(2).Value='10.2.2.209';

newRow(cb);
hPort=addSpinner(cb,10);
hPort(1).Text='Port:';
hPort(2).Value=23;
hPort(2).Limits=[1 65535];
hPort(2).Step=1;

newRow(cb);
hVISA=addEdit(cb,25);
hVISA(1).Text='VISA Resource:';
hVISA(2).Value='ASRL4::INSTR';
hVISA(1).Visible='off';
hVISA(2).Visible='off';

newRow(cb);
hConnect=addButton(cb,12);
hConnect.Text='Connect';
hConnect.ButtonPushedFcn=@connectPico;

hDisconnect=addButton(cb,12);
hDisconnect.Text='Disconnect';
hDisconnect.Enable='off';
hDisconnect.ButtonPushedFcn=@disconnectPico;

hConnStatus=addMessage(cb,20,1);
hConnStatus.Text='Not Connected';
hConnStatus.FontColor=[0.75 0.3 0];

newRow(cb);
newRow(cb);

%% ---- Driver 1 ----
hD1Label=addMessage(cb,40,1);
hD1Label.Text='=== Driver 1 ===';
hD1Label.FontWeight='bold';

newRow(cb);
h=addMessage(cb,8,1); h.Text='Axis 0:';
hD1A0P=addButton(cb,7); hD1A0P.Text='+Move'; hD1A0P.Enable='off';
hD1A0N=addButton(cb,7); hD1A0N.Text='-Move'; hD1A0N.Enable='off';
h=addMessage(cb,9,1); h.Text='Position:';
hPosD1A0=addSpinner(cb,8);
hPosD1A0(1).Text='';
hPosD1A0(2).Value=0;
hPosD1A0(2).Limits=[-1e6 1e6];
hPosD1A0(2).Editable='off';
h=addMessage(cb,5,1); h.Text='steps';

newRow(cb);
h=addMessage(cb,8,1); h.Text='Axis 1:';
hD1A1P=addButton(cb,7); hD1A1P.Text='+Move'; hD1A1P.Enable='off';
hD1A1N=addButton(cb,7); hD1A1N.Text='-Move'; hD1A1N.Enable='off';
h=addMessage(cb,9,1); h.Text='Position:';
hPosD1A1=addSpinner(cb,8);
hPosD1A1(1).Text='';
hPosD1A1(2).Value=0;
hPosD1A1(2).Limits=[-1e6 1e6];
hPosD1A1(2).Editable='off';
h=addMessage(cb,5,1); h.Text='steps';

newRow(cb);
newRow(cb);

%% ---- Driver 2 ----
hD2Label=addMessage(cb,40,1);
hD2Label.Text='=== Driver 2 ===';
hD2Label.FontWeight='bold';

newRow(cb);
h=addMessage(cb,8,1); h.Text='Axis 0:';
hD2A0P=addButton(cb,7); hD2A0P.Text='+Move'; hD2A0P.Enable='off';
hD2A0N=addButton(cb,7); hD2A0N.Text='-Move'; hD2A0N.Enable='off';
h=addMessage(cb,9,1); h.Text='Position:';
hPosD2A0=addSpinner(cb,8);
hPosD2A0(1).Text='';
hPosD2A0(2).Value=0;
hPosD2A0(2).Limits=[-1e6 1e6];
hPosD2A0(2).Editable='off';
h=addMessage(cb,5,1); h.Text='steps';

newRow(cb);
h=addMessage(cb,8,1); h.Text='Axis 1:';
hD2A1P=addButton(cb,7); hD2A1P.Text='+Move'; hD2A1P.Enable='off';
hD2A1N=addButton(cb,7); hD2A1N.Text='-Move'; hD2A1N.Enable='off';
h=addMessage(cb,9,1); h.Text='Position:';
hPosD2A1=addSpinner(cb,8);
hPosD2A1(1).Text='';
hPosD2A1(2).Value=0;
hPosD2A1(2).Limits=[-1e6 1e6];
hPosD2A1(2).Editable='off';
h=addMessage(cb,5,1); h.Text='steps';

newRow(cb);
newRow(cb);

%% ---- Step Size + Define Zero ----
hStepLabel=addMessage(cb,40,1);
hStepLabel.Text='=== Movement Settings ===';
hStepLabel.FontWeight='bold';

newRow(cb);
hStepSize=addSpinner(cb,10);
hStepSize(1).Text='Step Size:';
hStepSize(2).Value=1;
hStepSize(2).Limits=[1 10000];
hStepSize(2).Step=1;

hZero=addButton(cb,14);
hZero.Text='Define Zero';
hZero.Enable='off';
hZero.ButtonPushedFcn=@doDefineZero;

newRow(cb);
newRow(cb);

%% ---- Lissajous Section ----
hLisLabel=addMessage(cb,40,1);
hLisLabel.Text='=== Lissajous Alignment ===';
hLisLabel.FontWeight='bold';

newRow(cb);
hScopeSelect=addSpinner(cb,8);
hScopeSelect(1).Text='Scope #:';
hScopeSelect(2).Value=1;
hScopeSelect(2).Limits=[1 4];
hScopeSelect(2).Step=1;

hScopeDDG=addButton(cb,18);
hScopeDDG.Text='Set Scope && DDG';
hScopeDDG.Enable='off';
hScopeDDG.ButtonPushedFcn=@setScopeAndDDG;

newRow(cb);
hAcqPoints=addSpinner(cb,10);
hAcqPoints(1).Text='Acq Points:';
hAcqPoints(2).Value=500;
hAcqPoints(2).Limits=[100 100000];
hAcqPoints(2).Step=100;

newRow(cb);
h=addMessage(cb,10,1); h.Text='Channels:';
hCh1=addCheckbox(cb); hCh1.Text='CH1'; hCh1.Value=1;
hCh2=addCheckbox(cb); hCh2.Text='CH2'; hCh2.Value=1;
hCh3=addCheckbox(cb); hCh3.Text='CH3'; hCh3.Value=1;
hCh4=addCheckbox(cb); hCh4.Text='CH4'; hCh4.Value=1;

newRow(cb);
hMonitor=addButton(cb,18);
hMonitor.Text='Monitor Lissajous';
hMonitor.Enable='off';
hMonitor.ButtonPushedFcn=@monitorLissajous;

hStopLis=addButton(cb,16);
hStopLis.Text='Stop && Save Lis';
hStopLis.Enable='off';
hStopLis.ButtonPushedFcn=@stopAndSaveLissajous;

hSaveEx=addButton(cb,14);
hSaveEx.Text='Save Example';
hSaveEx.Enable='off';
hSaveEx.ButtonPushedFcn=@saveExample;

newRow(cb);
newRow(cb);

%% ---- Status ----
hLog=addTextarea(cb,50,4);
hLog(1).Text='Status:';
hLog(2).Value={'Picomotor panel ready.'};
hLog(2).Editable='off';

newRow(cb);
hDone=addButton(cb,16);
hDone.Text='Alignment Done';
hDone.ButtonPushedFcn=@closePanel;

%% ---- Assign Move Callbacks ----
hD1A0P.ButtonPushedFcn=@(~,~) doMove(1,0,+1);
hD1A0N.ButtonPushedFcn=@(~,~) doMove(1,0,-1);
hD1A1P.ButtonPushedFcn=@(~,~) doMove(1,1,+1);
hD1A1N.ButtonPushedFcn=@(~,~) doMove(1,1,-1);
hD2A0P.ButtonPushedFcn=@(~,~) doMove(2,0,+1);
hD2A0N.ButtonPushedFcn=@(~,~) doMove(2,0,-1);
hD2A1P.ButtonPushedFcn=@(~,~) doMove(2,1,+1);
hD2A1N.ButtonPushedFcn=@(~,~) doMove(2,1,-1);

fit(cb);
locate(cb);
show(cb);

%% =========================================================================
%  HELPERS
%% =========================================================================

    function addLog(message)
        currentLog=hLog(2).Value;
        timestamp=datestr(now,'HH:MM:SS'); %#ok<TNOW1,DATST>
        newEntry=sprintf('[%s] %s',timestamp,message);
        if length(currentLog) > 100
            currentLog=currentLog(end-99:end);
        end
        hLog(2).Value=[currentLog; {newEntry}];
        drawnow;
    end

    function updateUI()
        state='off';
        if connected; state='on'; end
        hD1A0P.Enable=state;
        hD1A0N.Enable=state;
        hD1A1P.Enable=state;
        hD1A1N.Enable=state;
        hD2A0P.Enable=state;
        hD2A0N.Enable=state;
        hD2A1P.Enable=state;
        hD2A1N.Enable=state;
        hZero.Enable=state;
        hScopeDDG.Enable=state;
        hMonitor.Enable=state;
        hStopLis.Enable=state;
        hSaveEx.Enable=state;
    end

    function updatePositions()
        if ~connected; return; end
        hPosD1A0(2).Value=pico.Position(1);
        hPosD1A1(2).Value=pico.Position(2);
        hPosD2A0(2).Value=pico.Position(3);
        hPosD2A1(2).Value=pico.Position(4);
    end

%% =========================================================================
%  CALLBACKS
%% =========================================================================

    function connectionTypeChanged(varargin)
        connType=hConnType(2).Value;
        if strcmp(connType,'TCP/IP')
            hIPAddr(1).Visible='on'; hIPAddr(2).Visible='on';
            hPort(1).Visible='on'; hPort(2).Visible='on';
            hVISA(1).Visible='off'; hVISA(2).Visible='off';
        else
            hIPAddr(1).Visible='off'; hIPAddr(2).Visible='off';
            hPort(1).Visible='off'; hPort(2).Visible='off';
            hVISA(1).Visible='on'; hVISA(2).Visible='on';
        end
    end

    function connectPico(varargin)
        connType=hConnType(2).Value;
        addLog(sprintf('Connecting via %s...',connType));
        try
            if strcmp(connType,'TCP/IP')
                ip=hIPAddr(2).Value;
                port=hPort(2).Value;
                pico=tcpConnectFcn(ip,port);
            else
                resource=hVISA(2).Value;
                pico=visaConnectFcn(resource);
            end
            connected=true;
            hConnStatus.Text=sprintf('Connected (%s)',pico.ConnectionType);
            hConnStatus.FontColor=[0 0.55 0];
            hConnect.Enable='off';
            hDisconnect.Enable='on';
            updateUI();
            updatePositions();
            addLog(sprintf('Connected via %s. Default setup complete.',connType));
        catch ME
            hConnStatus.Text='Connection Failed';
            hConnStatus.FontColor=[0.8 0 0];
            addLog(sprintf('Connection failed: %s',ME.message));
        end
    end

    function disconnectPico(varargin)
        try
            if ~isempty(pico)
                delete(pico);
            end
        catch
        end
        pico=[];
        connected=false;
        hConnStatus.Text='Not Connected';
        hConnStatus.FontColor=[0.75 0.3 0];
        hConnect.Enable='on';
        hDisconnect.Enable='off';
        updateUI();
        addLog('Disconnected');
    end

    function doMove(drive,axis,direction)
        if ~connected; return; end
        steps=hStepSize(2).Value*direction;
        addLog(sprintf('Moving D%dA%d: %+d steps...',drive,axis,steps));
        try
            moveRelative(pico,drive,axis,steps);
            updatePositions();
            axisIndex=2*(drive-1)+axis+1;
            addLog(sprintf('Move complete. D%dA%d = %d steps',drive,axis,pico.Position(axisIndex)));
        catch ME
            addLog(sprintf('Move error: %s',ME.message));
        end
    end

    function doDefineZero(varargin)
        if ~connected; return; end
        defineZero(pico);
        updatePositions();
        addLog('All position counters reset to zero');
    end

    function setScopeAndDDG(varargin)
        sn=hScopeSelect(2).Value;
        pts=hAcqPoints(2).Value;
        addLog(sprintf('Set Scope %d && DDG for alignment. Points=%d. (App logic pending)',sn,pts));
    end

    function monitorLissajous(varargin)
        sn=hScopeSelect(2).Value;
        ch=[hCh1.Value hCh2.Value hCh3.Value hCh4.Value];
        addLog(sprintf('Monitor Lissajous: Scope %d, CH[%d%d%d%d]. (App logic pending)',sn,ch));
    end

    function stopAndSaveLissajous(varargin)
        addLog('Lissajous acquisition stopped. (App logic pending)');
    end

    function saveExample(varargin)
        addLog('Save example trace flagged. (App logic pending)');
    end

    function closePanel(varargin)
        if connected
            disconnectPico();
        end
        addLog('Alignment done. Closing panel...');
        pause(0.3);
        delete(cb.Figure);
    end

end