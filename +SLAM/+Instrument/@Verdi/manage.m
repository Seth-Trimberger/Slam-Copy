% manage Verdi laser control panel
%
% This *static* method launches a GUI panel for controlling the Coherent
% Verdi V-10 laser.
%    Verdi.manage();
%
% The panel provides:
%   - VISA connection management
%   - Power control and readback
%   - Shutter open/close with safety interlocks
%   - Etalon flash
%   - RS-232 echo control
%
% Button grayout rules:
%   - ALL controls require laser to be connected
%   - Open/Close Shutter disabled when DDG Shot Mode is active
%     (in shot mode the DDG controls shutter timing via the AOM)
%   - Set Output Power disabled while shutter is known to be OPEN
%     (safety: do not change power level while beam is live)
%   - Flash Etalon requires laser connected only
%
% See also Verdi, connect
%
function manage()

cb=SLAM.Developer.ComponentBox();
setName(cb,'Verdi V-10 Laser Control');
setFont(cb,'Consolas');

% shared state (closure variables)
laser=[];
connected=false;
shutterOpen=false;
ddgShotMode=false;

% resolve package-safe connect function
persistent connectFcn
if isempty(connectFcn)
    location=fileparts(fileparts(mfilename("fullpath")));
    package=extractAfter(location,'+');
    package=strrep(package,[filesep '+'],'.');
    connectFcn=str2func([package '.Verdi.connect']);
end

%% ---- Title ----
hTitle=addMessage(cb,40,1);
hTitle.Text='Coherent Verdi V-10 Laser';
hTitle.FontWeight='bold';
hTitle.FontSize=14;

newRow(cb);
hStatus=addMessage(cb,40,1);
hStatus.Text='Status: Not Connected';

newRow(cb);
hMode=addMessage(cb,40,1);
hMode.Text='Mode: Alignment / Standby';

newRow(cb);

%% ---- Connection ----
hAddr=addEdit(cb,30);
hAddr(1).Text='VISA Address:';
hAddr(2).Value='ASRL4::INSTR';

newRow(cb);

hConnect=addButton(cb,15);
hConnect.Text='Connect';
hConnect.ButtonPushedFcn=@connectLaser;

hDisconnect=addButton(cb,15);
hDisconnect.Text='Disconnect';
hDisconnect.Enable='off';
hDisconnect.ButtonPushedFcn=@disconnectLaser;

newRow(cb);
newRow(cb);

%% ---- Power Control ----
hPowerLabel=addMessage(cb,40,1);
hPowerLabel.Text='=== Power Control ===';
hPowerLabel.FontWeight='bold';

newRow(cb);
hPowerSpin=addSpinner(cb,25);
hPowerSpin(1).Text='Set Power (W):';
hPowerSpin(2).Value=5.0000;
hPowerSpin(2).Limits=[0.0001 10.9999];
hPowerSpin(2).Step=0.1;
hPowerSpin(2).ValueDisplayFormat='%.4f';
hPowerSpin(2).Enable='off';

newRow(cb);
hSetPower=addButton(cb,20);
hSetPower.Text='Set Output Power';
hSetPower.Enable='off';
hSetPower.ButtonPushedFcn=@setPower;

newRow(cb);
hGetSetpoint=addButton(cb,20);
hGetSetpoint.Text='Query Power Setpoint';
hGetSetpoint.Enable='off';
hGetSetpoint.ButtonPushedFcn=@querySetpoint;

newRow(cb);
hGetLight=addButton(cb,20);
hGetLight.Text='Query Actual Light Output';
hGetLight.Enable='off';
hGetLight.ButtonPushedFcn=@queryLight;

newRow(cb);
hReadback=addEdit(cb,25);
hReadback(1).Text='Power Readback (W):';
hReadback(2).Value='---';
hReadback(2).Editable='off';

newRow(cb);
newRow(cb);

%% ---- Shutter Control ----
hShutterLabel=addMessage(cb,40,1);
hShutterLabel.Text='=== Shutter Control ===';
hShutterLabel.FontWeight='bold';

newRow(cb);
hShutterStatus=addEdit(cb,25);
hShutterStatus(1).Text='Shutter Status:';
hShutterStatus(2).Value='--- Unknown ---';
hShutterStatus(2).Editable='off';

newRow(cb);
hOpen=addButton(cb,15);
hOpen.Text='Open Shutter';
hOpen.Enable='off';
hOpen.ButtonPushedFcn=@openShutter;

hClose=addButton(cb,15);
hClose.Text='Close Shutter';
hClose.Enable='off';
hClose.ButtonPushedFcn=@closeShutter;

newRow(cb);
hGetShutter=addButton(cb,20);
hGetShutter.Text='Query Shutter Status';
hGetShutter.Enable='off';
hGetShutter.ButtonPushedFcn=@queryShutter;

newRow(cb);
newRow(cb);

%% ---- Shot Preparation ----
hShotLabel=addMessage(cb,40,1);
hShotLabel.Text='=== Shot Preparation ===';
hShotLabel.FontWeight='bold';

newRow(cb);
hShotNote=addMessage(cb,50,2);
hShotNote.Text={'Flash Etalon (FLASH=1) is also called automatically', ...
    'by Set For Shot in the main panel.'};
hShotNote.FontSize=10;

newRow(cb);
hFlash=addButton(cb,20);
hFlash.Text='Flash Etalon  (FLASH=1)';
hFlash.Enable='off';
hFlash.ButtonPushedFcn=@doFlash;

newRow(cb);
newRow(cb);

%% ---- Diagnostics ----
hDiagLabel=addMessage(cb,40,1);
hDiagLabel.Text='=== Diagnostics ===';
hDiagLabel.FontWeight='bold';

newRow(cb);
hEcho=addDropdown(cb,25);
hEcho(1).Text='RS-232 Echo:';
hEcho(2).Items={'Echo Off  (ECHO=0)','Echo On  (ECHO=1)'};
hEcho(2).Value='Echo Off  (ECHO=0)';
hEcho(2).Enable='off';

newRow(cb);
hSetEcho=addButton(cb,20);
hSetEcho.Text='Set Echo Mode';
hSetEcho.Enable='off';
hSetEcho.ButtonPushedFcn=@setEcho;

newRow(cb);
newRow(cb);

%% ---- Activity Log ----
hLog=addTextarea(cb,50,6);
hLog(1).Text='Activity Log:';
hLog(2).Value={'Verdi Laser GUI initialized','Ready to connect'};
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
            % everything off
            hSetPower.Enable='off';
            hPowerSpin(2).Enable='off';
            hGetSetpoint.Enable='off';
            hGetLight.Enable='off';
            hOpen.Enable='off';
            hClose.Enable='off';
            hGetShutter.Enable='off';
            hFlash.Enable='off';
            hEcho(2).Enable='off';
            hSetEcho.Enable='off';
            hMode.Text='Mode: Alignment / Standby';
            hMode.FontColor=[0 0 0];
        else
            % base controls on
            hGetSetpoint.Enable='on';
            hGetLight.Enable='on';
            hGetShutter.Enable='on';
            hFlash.Enable='on';
            hEcho(2).Enable='on';
            hSetEcho.Enable='on';

            % power: disabled while shutter is open (safety)
            if shutterOpen
                hSetPower.Enable='off';
                hPowerSpin(2).Enable='off';
            else
                hSetPower.Enable='on';
                hPowerSpin(2).Enable='on';
            end

            % shutter: disabled in DDG shot mode
            if ddgShotMode
                hOpen.Enable='off';
                hClose.Enable='off';
                hMode.Text='Mode: DDG Shot Mode Active  (shutter via DDG)';
                hMode.FontColor=[0.75 0.40 0];
            else
                hOpen.Enable='on';
                hClose.Enable='on';
                hMode.Text='Mode: Alignment / Standby';
                hMode.FontColor=[0.25 0.25 0.55];
            end
        end
    end

%% =========================================================================
%  CALLBACKS
%% =========================================================================

    function connectLaser(varargin)
        try
            addLog('Attempting to connect to Verdi laser...');
            resource=hAddr(2).Value;
            laser=connectFcn(resource);
            connected=true;

            hStatus.Text=sprintf('Status: Connected (%s)',resource);
            hStatus.FontColor=[0 0.6 0];
            hConnect.Enable='off';
            hDisconnect.Enable='on';
            hAddr(2).Editable='off';

            updateUI();
            addLog(sprintf('Successfully connected to %s',resource));
        catch ME
            addLog(sprintf('Connection failed: %s',ME.message));
            laser=[];
            connected=false;
        end
    end

    function disconnectLaser(varargin)
        try
            if ~isempty(laser)
                delete(laser);
            end
        catch
        end

        laser=[];
        connected=false;
        shutterOpen=false;

        hStatus.Text='Status: Not Connected';
        hStatus.FontColor=[0 0 0];
        hConnect.Enable='on';
        hDisconnect.Enable='off';
        hAddr(2).Editable='on';
        hReadback(2).Value='---';
        hShutterStatus(2).Value='--- Unknown ---';
        hShutterStatus(2).FontColor=[0 0 0];

        updateUI();
        addLog('Disconnected from Verdi laser');
    end

    function setPower(varargin)
        if ~connected; return; end
        power=hPowerSpin(2).Value;
        addLog(sprintf('Setting output power to %.4f W...',power));
        try
            setOutputPower(laser,power);
            addLog(sprintf('Power set to %.4f W',power));
        catch ME
            addLog(sprintf('Error setting power: %s',ME.message));
        end
    end

    function querySetpoint(varargin)
        if ~connected; return; end
        addLog('Querying power setpoint...');
        try
            power=getPowerSetpoint(laser);
            hReadback(2).Value=sprintf('%.4f W  (setpoint)',power);
            addLog(sprintf('Power setpoint: %.4f W',power));
        catch ME
            addLog(sprintf('Error querying setpoint: %s',ME.message));
        end
    end

    function queryLight(varargin)
        if ~connected; return; end
        addLog('Querying actual light output...');
        try
            power=getActualLightOutput(laser);
            hReadback(2).Value=sprintf('%.4f W  (actual output)',power);
            addLog(sprintf('Actual light output: %.4f W',power));
        catch ME
            addLog(sprintf('Error querying light output: %s',ME.message));
        end
    end

    function openShutter(varargin)
        if ~connected; return; end
        if ddgShotMode
            addLog('Blocked: In shot mode the shutter is controlled by DDG timing');
            return
        end
        addLog('Opening shutter...');
        try
            controlShutter(laser,1);
            hShutterStatus(2).Value='OPEN';
            hShutterStatus(2).FontColor=[0.80 0.15 0.05];
            shutterOpen=true;
            updateUI();
            addLog('Shutter opened  —  power control locked');
        catch ME
            addLog(sprintf('Error opening shutter: %s',ME.message));
        end
    end

    function closeShutter(varargin)
        if ~connected; return; end
        if ddgShotMode
            addLog('Blocked: In shot mode the shutter is controlled by DDG timing');
            return
        end
        addLog('Closing shutter...');
        try
            controlShutter(laser,0);
            hShutterStatus(2).Value='CLOSED';
            hShutterStatus(2).FontColor=[0.05 0.50 0.10];
            shutterOpen=false;
            updateUI();
            addLog('Shutter closed  —  power control unlocked');
        catch ME
            addLog(sprintf('Error closing shutter: %s',ME.message));
        end
    end

    function queryShutter(varargin)
        if ~connected; return; end
        addLog('Querying shutter status...');
        try
            status=getShutterStatus(laser);
            if status == 1
                hShutterStatus(2).Value='OPEN';
                hShutterStatus(2).FontColor=[0.80 0.15 0.05];
                shutterOpen=true;
                updateUI();
                addLog('Shutter status: OPEN  —  power control locked');
            elseif status == 0
                hShutterStatus(2).Value='CLOSED';
                hShutterStatus(2).FontColor=[0.05 0.50 0.10];
                shutterOpen=false;
                updateUI();
                addLog('Shutter status: CLOSED');
            else
                hShutterStatus(2).Value='--- Unknown ---';
                hShutterStatus(2).FontColor=[0.40 0.40 0.40];
                addLog('Warning: Unexpected shutter response from laser');
            end
        catch ME
            addLog(sprintf('Error querying shutter: %s',ME.message));
        end
    end

    function doFlash(varargin)
        if ~connected; return; end
        addLog('Flashing etalon (FLASH=1)...');
        try
            flashEtalon(laser);
            addLog('Etalon flash complete');
        catch ME
            addLog(sprintf('Error flashing etalon: %s',ME.message));
        end
    end

    function setEcho(varargin)
        if ~connected; return; end
        if contains(hEcho(2).Value,'1')
            echoVal=1;
        else
            echoVal=0;
        end
        addLog(sprintf('Setting echo mode to %d...',echoVal));
        try
            controlEcho(laser,echoVal);
            addLog(sprintf('Echo mode set to %d',echoVal));
        catch ME
            addLog(sprintf('Error setting echo: %s',ME.message));
        end
    end

    function closePanel(varargin)
        if connected
            disconnectLaser();
        end
        delete(cb.Figure);
    end

end