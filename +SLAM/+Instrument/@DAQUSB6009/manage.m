% manage DAQ beam paddle control panel
%
% This *static* method launches a GUI panel for controlling the NI
% USB-6009 beam-blocking solenoids (paddles) in the VISAR interferometer.
%    DAQUSB6009.manage();
%
% The panel provides:
%   - Device connection management
%   - Individual paddle control (PZT / Etalon legs)
%   - Block all / Unblock all convenience buttons
%   - Raw digital output write (legacy DAQdigOut compatibility)
%   - Live state display
%
% See also DAQUSB6009, connect
%
function manage()

cb=SLAM.Developer.ComponentBox();
setName(cb,'NI USB-6009 Beam Paddle Control');
setFont(cb,'Consolas');

% shared state (closure variables)
daq=[];
connected=false;

% resolve package-safe function handles
persistent connectFcn listFcn
if isempty(connectFcn)
    location=fileparts(fileparts(mfilename("fullpath")));
    package=extractAfter(location,'+');
    package=strrep(package,[filesep '+'],'.');
    connectFcn=str2func([package '.DAQUSB6009.connect']);
    listFcn=str2func([package '.DAQUSB6009.listDevices']);
end

%% ---- Title ----
hTitle=addMessage(cb,40,1);
hTitle.Text='NI USB-6009 Beam Paddle Control';
hTitle.FontWeight='bold';
hTitle.FontSize=14;

newRow(cb);
hStatus=addMessage(cb,40,1);
hStatus.Text='Status: Not Connected';

newRow(cb);

%% ---- Connection ----
hDevice=addEdit(cb,25);
hDevice(1).Text='Device Name:';
hDevice(2).Value='Dev3';

newRow(cb);

hConnect=addButton(cb,15);
hConnect.Text='Connect';
hConnect.ButtonPushedFcn=@connectDAQ;

hDisconnect=addButton(cb,15);
hDisconnect.Text='Disconnect';
hDisconnect.Enable='off';
hDisconnect.ButtonPushedFcn=@disconnectDAQ;

hList=addButton(cb,15);
hList.Text='List Devices';
hList.ButtonPushedFcn=@doListDevices;

newRow(cb);
newRow(cb);

%% ---- Paddle State Display ----
hStateLabel=addMessage(cb,40,1);
hStateLabel.Text='=== Paddle State ===';
hStateLabel.FontWeight='bold';

newRow(cb);
hPZTState=addEdit(cb,20);
hPZTState(1).Text='PZT Leg:';
hPZTState(2).Value='---';
hPZTState(2).Editable='off';

newRow(cb);
hETAState=addEdit(cb,20);
hETAState(1).Text='Etalon Leg:';
hETAState(2).Value='---';
hETAState(2).Editable='off';

newRow(cb);
hRawState=addEdit(cb,20);
hRawState(1).Text='Raw Pattern:';
hRawState(2).Value='---';
hRawState(2).Editable='off';

newRow(cb);
newRow(cb);

%% ---- Individual Paddle Control ----
hIndLabel=addMessage(cb,40,1);
hIndLabel.Text='=== Individual Paddle Control ===';
hIndLabel.FontWeight='bold';

newRow(cb);
hBlockPZT=addButton(cb,15);
hBlockPZT.Text='Block PZT';
hBlockPZT.Enable='off';
hBlockPZT.ButtonPushedFcn=@doBlockPZT;

hUnblockPZT=addButton(cb,15);
hUnblockPZT.Text='Unblock PZT';
hUnblockPZT.Enable='off';
hUnblockPZT.ButtonPushedFcn=@doUnblockPZT;

newRow(cb);
hBlockETA=addButton(cb,15);
hBlockETA.Text='Block Etalon';
hBlockETA.Enable='off';
hBlockETA.ButtonPushedFcn=@doBlockEtalon;

hUnblockETA=addButton(cb,15);
hUnblockETA.Text='Unblock Etalon';
hUnblockETA.Enable='off';
hUnblockETA.ButtonPushedFcn=@doUnblockEtalon;

newRow(cb);
newRow(cb);

%% ---- Bulk Control ----
hBulkLabel=addMessage(cb,40,1);
hBulkLabel.Text='=== Bulk Control ===';
hBulkLabel.FontWeight='bold';

newRow(cb);
hBlockAll=addButton(cb,15);
hBlockAll.Text='Block All';
hBlockAll.Enable='off';
hBlockAll.ButtonPushedFcn=@doBlockAll;

hUnblockAll=addButton(cb,15);
hUnblockAll.Text='Unblock All';
hUnblockAll.Enable='off';
hUnblockAll.ButtonPushedFcn=@doUnblockAll;

newRow(cb);
newRow(cb);

%% ---- Raw Write ----
hRawLabel=addMessage(cb,40,1);
hRawLabel.Text='=== Raw Digital Output ===';
hRawLabel.FontWeight='bold';

newRow(cb);
hRawNote=addMessage(cb,50,1);
hRawNote.Text='Legacy DAQdigOut: 0=clear, 1=PZT, 2=ETA, 3=both';
hRawNote.FontSize=10;

newRow(cb);
hRawSpin=addSpinner(cb,20);
hRawSpin(1).Text='Raw Value (0-255):';
hRawSpin(2).Value=0;
hRawSpin(2).Limits=[0 255];
hRawSpin(2).Step=1;
hRawSpin(2).ValueDisplayFormat='%d';
hRawSpin(2).Enable='off';

newRow(cb);
hRawWrite=addButton(cb,20);
hRawWrite.Text='Write Raw Value';
hRawWrite.Enable='off';
hRawWrite.ButtonPushedFcn=@doWriteRaw;

newRow(cb);
newRow(cb);

%% ---- Activity Log ----
hLog=addTextarea(cb,50,5);
hLog(1).Text='Activity Log:';
hLog(2).Value={'DAQ Paddle GUI initialized','Ready to connect'};
hLog(2).Editable='off';

newRow(cb);
hDone=addButton(cb,10);
hDone.Text='Close';
hDone.ButtonPushedFcn=@closePanel;

fit(cb);
locate(cb);
show(cb);

%% =========================================================================
%  HELPER FUNCTIONS
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
        if ~connected
            hBlockPZT.Enable='off';
            hUnblockPZT.Enable='off';
            hBlockETA.Enable='off';
            hUnblockETA.Enable='off';
            hBlockAll.Enable='off';
            hUnblockAll.Enable='off';
            hRawSpin(2).Enable='off';
            hRawWrite.Enable='off';
            hPZTState(2).Value='---';
            hETAState(2).Value='---';
            hRawState(2).Value='---';
            hPZTState(2).FontColor=[0 0 0];
            hETAState(2).FontColor=[0 0 0];
        else
            hBlockPZT.Enable='on';
            hUnblockPZT.Enable='on';
            hBlockETA.Enable='on';
            hUnblockETA.Enable='on';
            hBlockAll.Enable='on';
            hUnblockAll.Enable='on';
            hRawSpin(2).Enable='on';
            hRawWrite.Enable='on';
            refreshState();
        end
    end

    function refreshState()
        if ~connected; return; end
        s=getState(daq);
        if s.pzt
            hPZTState(2).Value='BLOCKED';
            hPZTState(2).FontColor=[0.80 0.15 0.05];
        else
            hPZTState(2).Value='UNBLOCKED';
            hPZTState(2).FontColor=[0.05 0.50 0.10];
        end
        if s.etalon
            hETAState(2).Value='BLOCKED';
            hETAState(2).FontColor=[0.80 0.15 0.05];
        else
            hETAState(2).Value='UNBLOCKED';
            hETAState(2).FontColor=[0.05 0.50 0.10];
        end
        hRawState(2).Value=sprintf('%d',s.raw);
    end

%% =========================================================================
%  CALLBACKS
%% =========================================================================

    function connectDAQ(varargin)
        try
            deviceName=hDevice(2).Value;
            addLog(sprintf('Connecting to %s...',deviceName));
            daq=connectFcn(deviceName);
            connected=true;

            hStatus.Text=sprintf('Status: Connected (%s)',deviceName);
            hStatus.FontColor=[0 0.6 0];
            hConnect.Enable='off';
            hDisconnect.Enable='on';
            hDevice(2).Editable='off';

            updateUI();
            addLog(sprintf('Connected to %s',deviceName));
        catch ME
            addLog(sprintf('Connection failed: %s',ME.message));
            daq=[];
            connected=false;
        end
    end

    function disconnectDAQ(varargin)
        try
            if ~isempty(daq)
                delete(daq);
            end
        catch
        end

        daq=[];
        connected=false;

        hStatus.Text='Status: Not Connected';
        hStatus.FontColor=[0 0 0];
        hConnect.Enable='on';
        hDisconnect.Enable='off';
        hDevice(2).Editable='on';

        updateUI();
        addLog('Disconnected from DAQ');
    end

    function doListDevices(varargin)
        addLog('Listing NI-DAQ devices...');
        try
            listFcn();
            addLog('Device list printed to command window');
        catch ME
            addLog(sprintf('Error listing devices: %s',ME.message));
        end
    end

    function doBlockPZT(varargin)
        if ~connected; return; end
        try
            blockPZT(daq);
            refreshState();
            addLog('PZT leg BLOCKED');
        catch ME
            addLog(sprintf('Error: %s',ME.message));
        end
    end

    function doUnblockPZT(varargin)
        if ~connected; return; end
        try
            unblockPZT(daq);
            refreshState();
            addLog('PZT leg UNBLOCKED');
        catch ME
            addLog(sprintf('Error: %s',ME.message));
        end
    end

    function doBlockEtalon(varargin)
        if ~connected; return; end
        try
            blockEtalon(daq);
            refreshState();
            addLog('Etalon leg BLOCKED');
        catch ME
            addLog(sprintf('Error: %s',ME.message));
        end
    end

    function doUnblockEtalon(varargin)
        if ~connected; return; end
        try
            unblockEtalon(daq);
            refreshState();
            addLog('Etalon leg UNBLOCKED');
        catch ME
            addLog(sprintf('Error: %s',ME.message));
        end
    end

    function doBlockAll(varargin)
        if ~connected; return; end
        try
            blockAll(daq);
            refreshState();
            addLog('Both legs BLOCKED');
        catch ME
            addLog(sprintf('Error: %s',ME.message));
        end
    end

    function doUnblockAll(varargin)
        if ~connected; return; end
        try
            unblockAll(daq);
            refreshState();
            addLog('Both legs UNBLOCKED');
        catch ME
            addLog(sprintf('Error: %s',ME.message));
        end
    end

    function doWriteRaw(varargin)
        if ~connected; return; end
        value=hRawSpin(2).Value;
        try
            writeRaw(daq,value);
            refreshState();
            addLog(sprintf('Raw write: %d',value));
        catch ME
            addLog(sprintf('Error: %s',ME.message));
        end
    end

    function closePanel(varargin)
        if connected
            disconnectDAQ();
        end
        delete(cb.Figure);
    end

end