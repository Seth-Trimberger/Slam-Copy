function VERDILASERGUI()
% VERDILASERGUI Control interface for the Coherent Verdi V-10 laser
%
% This GUI provides control of the Verdi laser with proper UI state
% management based on connection status and system mode (shot vs alignment).
%
% Button grayout rules:
%   - ALL controls require laser to be connected
%   - Open/Close Shutter disabled when DDG Shot Mode is active
%     (in shot mode the DDG controls shutter timing via the AOM)
%   - Set Output Power disabled while shutter is known to be OPEN
%     (safety: do not change power level while beam is live)
%   - Flash Etalon requires laser connected only
%
% Hardware class: Verdi_Lasers.m
% Documentation:  https://github.com/quantumm/user_manual/blob/main/Coherent_VerdiV10_UserManual.pdf

import SLAM.Developer.ComponentBox

cb = ComponentBox('hide');
setFont(cb, 'Consolas')
setName(cb, 'Verdi V-10 Laser Control');

%% ---- Title ----
h = addMessage(cb, 40, 1);
h.Text = 'Coherent Verdi V-10 Laser';
h.FontWeight = 'bold';
h.FontSize = 14;

newRow(cb);
h = addMessage(cb, 40, 1);
h.Text = 'Status: Not Connected';
h.Tag = 'StatusMsg';

newRow(cb);
h = addMessage(cb, 40, 1);
h.Text = 'Mode: Alignment / Standby';
h.Tag = 'ModeMsg';

newRow(cb);

%% ---- Connection ----
h = addEdit(cb, 30);
h(1).Text = 'VISA Address:';
h(2).Value = 'ASRL4::INSTR';
h(2).Tag = 'VisaAddress';

newRow(cb);

h = addButton(cb, 15);
h.Text = 'Connect';
h.Tag = 'ConnectBtn';
h.ButtonPushedFcn = @connectLaser;

h = addButton(cb, 15);
h.Text = 'Disconnect';
h.Tag = 'DisconnectBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @disconnectLaser;

newRow(cb);
newRow(cb);

%% ---- Power Control ----
h = addMessage(cb, 40, 1);
h.Text = '=== Power Control ===';
h.FontWeight = 'bold';

newRow(cb);
h = addSpinner(cb, 25);
h(1).Text = 'Set Power (W):';
h(2).Value = 5.0000;
h(2).Limits = [0.0001 10.9999];
h(2).Step = 0.1;
h(2).ValueDisplayFormat = '%.4f';
h(2).Tag = 'PowerSpinner';
h(2).Enable = 'off';

newRow(cb);
h = addButton(cb, 20);
h.Text = 'Set Output Power';
h.Tag = 'SetPowerBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @setOutputPower;

newRow(cb);
h = addButton(cb, 20);
h.Text = 'Query Power Setpoint';
h.Tag = 'GetSetpointBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @getPowerSetpoint;

newRow(cb);
h = addButton(cb, 20);
h.Text = 'Query Actual Light Output';
h.Tag = 'GetLightBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @getActualLight;

newRow(cb);
h = addEdit(cb, 25);
h(1).Text = 'Power Readback (W):';
h(2).Value = '---';
h(2).Editable = 'off';
h(2).Tag = 'PowerReadback';

newRow(cb);
newRow(cb);

%% ---- Shutter Control ----
h = addMessage(cb, 40, 1);
h.Text = '=== Shutter Control ===';
h.FontWeight = 'bold';

newRow(cb);
h = addEdit(cb, 25);
h(1).Text = 'Shutter Status:';
h(2).Value = '--- Unknown ---';
h(2).Editable = 'off';
h(2).Tag = 'ShutterStatus';

newRow(cb);

h = addButton(cb, 15);
h.Text = 'Open Shutter';
h.Tag = 'OpenShutterBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @openShutter;

h = addButton(cb, 15);
h.Text = 'Close Shutter';
h.Tag = 'CloseShutterBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @closeShutter;

newRow(cb);
h = addButton(cb, 20);
h.Text = 'Query Shutter Status';
h.Tag = 'GetShutterBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @queryShutterStatus;

newRow(cb);
newRow(cb);

%% ---- Shot Preparation ----
h = addMessage(cb, 40, 1);
h.Text = '=== Shot Preparation ===';
h.FontWeight = 'bold';

newRow(cb);
h = addMessage(cb, 50, 2);
h.Text = {'Flash Etalon (FLASH=1) is also called automatically', ...
          'by Set For Shot in the main panel.'};
h.FontSize = 10;

newRow(cb);
h = addButton(cb, 20);
h.Text = 'Flash Etalon  (FLASH=1)';
h.Tag = 'FlashEtalonBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @flashEtalon;

newRow(cb);
newRow(cb);

%% ---- Diagnostics ----
h = addMessage(cb, 40, 1);
h.Text = '=== Diagnostics ===';
h.FontWeight = 'bold';

newRow(cb);
h = addDropdown(cb, 25);
h(1).Text = 'RS-232 Echo:';
h(2).Items = {'Echo Off  (ECHO=0)', 'Echo On  (ECHO=1)'};
h(2).Value = 'Echo Off  (ECHO=0)';
h(2).Tag = 'EchoDropdown';
h(2).Enable = 'off';

newRow(cb);
h = addButton(cb, 20);
h.Text = 'Set Echo Mode';
h.Tag = 'SetEchoBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @setEchoMode;

newRow(cb);
newRow(cb);

%% ---- Activity Log ----
h = addTextarea(cb, 50, 6);
h(1).Text = 'Activity Log:';
h(2).Value = {'Verdi Laser GUI initialized', 'Ready to connect'};
h(2).Editable = 'off';
h(2).Tag = 'ActivityLog';

newRow(cb);
h = addButton(cb, 10);
h.Text = 'Close';
h.ButtonPushedFcn = @closeGUI;

fit(cb);
locate(cb);
show(cb);

% Store laser object and state in figure UserData
cb.Figure.UserData = struct( ...
    'Laser',       [], ...
    'Connected',   false, ...
    'DDGShotMode', false, ...
    'ShutterOpen', false);

uiwait(cb.Figure);

%% =========================================================================
%  CALLBACK FUNCTIONS
%% =========================================================================

    function connectLaser(varargin)
        handles = guihandles(cb.Figure);

        try
            addLog('Attempting to connect to Verdi laser...');

            visaAddress = handles.VisaAddress.Value;
            laser = Verdi_Lasers(visaAddress);

            cb.Figure.UserData.Laser     = laser;
            cb.Figure.UserData.Connected = true;

            handles.StatusMsg.Text       = sprintf('Status: Connected (%s)', visaAddress);
            handles.StatusMsg.FontColor  = [0 0.6 0];
            handles.ConnectBtn.Enable    = 'off';
            handles.DisconnectBtn.Enable = 'on';
            handles.VisaAddress.Editable = 'off';

            updateUIState();

            addLog(sprintf('Successfully connected to %s', visaAddress));

        catch ME
            addLog(sprintf('Connection failed: %s', ME.message));
            cb.Figure.UserData.Laser     = [];
            cb.Figure.UserData.Connected = false;
        end
    end

    %----------------------------------------------------------------------
    function disconnectLaser(varargin)
        handles = guihandles(cb.Figure);

        try
            if ~isempty(cb.Figure.UserData.Laser)
                try
                    delete(cb.Figure.UserData.Laser.VisaObj);
                catch
                    % Ignore cleanup errors
                end
            end

            cb.Figure.UserData.Laser       = [];
            cb.Figure.UserData.Connected   = false;
            cb.Figure.UserData.ShutterOpen = false;

            handles.StatusMsg.Text       = 'Status: Not Connected';
            handles.StatusMsg.FontColor  = [0 0 0];
            handles.ConnectBtn.Enable    = 'on';
            handles.DisconnectBtn.Enable = 'off';
            handles.VisaAddress.Editable = 'on';
            handles.ShutterStatus.Value  = '--- Unknown ---';
            handles.PowerReadback.Value  = '---';

            updateUIState();

            addLog('Disconnected from Verdi laser');

        catch ME
            addLog(sprintf('Disconnect error: %s', ME.message));
        end
    end

    %----------------------------------------------------------------------
    function updateUIState()
        % Enable/disable all controls based on connection and mode state
        handles = guihandles(cb.Figure);

        isConnected = cb.Figure.UserData.Connected;
        ddgShotMode = cb.Figure.UserData.DDGShotMode;
        shutterOpen = cb.Figure.UserData.ShutterOpen;

        if ~isConnected
            % Disable everything when not connected
            handles.PowerSpinner.Enable    = 'off';
            handles.SetPowerBtn.Enable     = 'off';
            handles.GetSetpointBtn.Enable  = 'off';
            handles.GetLightBtn.Enable     = 'off';
            handles.OpenShutterBtn.Enable  = 'off';
            handles.CloseShutterBtn.Enable = 'off';
            handles.GetShutterBtn.Enable   = 'off';
            handles.FlashEtalonBtn.Enable  = 'off';
            handles.EchoDropdown.Enable    = 'off';
            handles.SetEchoBtn.Enable      = 'off';

            handles.ModeMsg.Text      = 'Mode: Alignment / Standby';
            handles.ModeMsg.FontColor = [0 0 0];

        else
            % Connected — enable base controls
            handles.GetSetpointBtn.Enable = 'on';
            handles.GetLightBtn.Enable    = 'on';
            handles.GetShutterBtn.Enable  = 'on';
            handles.FlashEtalonBtn.Enable = 'on';
            handles.EchoDropdown.Enable   = 'on';
            handles.SetEchoBtn.Enable     = 'on';

            % Set Power: disabled while shutter is open (safety)
            if shutterOpen
                handles.SetPowerBtn.Enable  = 'off';
                handles.PowerSpinner.Enable = 'off';
            else
                handles.SetPowerBtn.Enable  = 'on';
                handles.PowerSpinner.Enable = 'on';
            end

            % Shutter Open/Close: disabled in DDG shot mode
            if ddgShotMode
                handles.OpenShutterBtn.Enable  = 'off';
                handles.CloseShutterBtn.Enable = 'off';
                handles.ModeMsg.Text      = 'Mode: DDG Shot Mode Active  (shutter via DDG)';
                handles.ModeMsg.FontColor = [0.75 0.40 0];
            else
                handles.OpenShutterBtn.Enable  = 'on';
                handles.CloseShutterBtn.Enable = 'on';
                handles.ModeMsg.Text      = 'Mode: Alignment / Standby';
                handles.ModeMsg.FontColor = [0.25 0.25 0.55];
            end
        end
    end

    %----------------------------------------------------------------------
    function setOutputPower(varargin)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to laser');
            return
        end

        handles = guihandles(cb.Figure);
        laser   = cb.Figure.UserData.Laser;
        power   = handles.PowerSpinner.Value;

        addLog(sprintf('Setting output power to %.4f W...', power));

        try
            laser.SetOutPutPower(power);
            addLog(sprintf('Power set to %.4f W', power));
        catch ME
            addLog(sprintf('Error setting power: %s', ME.message));
        end
    end

    %----------------------------------------------------------------------
    function getPowerSetpoint(varargin)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to laser');
            return
        end

        handles = guihandles(cb.Figure);
        laser   = cb.Figure.UserData.Laser;

        addLog('Querying power setpoint...');

        try
            power = laser.GetPowerSetpoint();
            handles.PowerReadback.Value = sprintf('%.4f W  (setpoint)', power);
            addLog(sprintf('Power setpoint: %.4f W', power));
        catch ME
            addLog(sprintf('Error querying setpoint: %s', ME.message));
        end
    end

    %----------------------------------------------------------------------
    function getActualLight(varargin)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to laser');
            return
        end

        handles = guihandles(cb.Figure);
        laser   = cb.Figure.UserData.Laser;

        addLog('Querying actual light output...');

        try
            power = laser.GetActualLightOutput();
            handles.PowerReadback.Value = sprintf('%.4f W  (actual output)', power);
            addLog(sprintf('Actual light output: %.4f W', power));
        catch ME
            addLog(sprintf('Error querying light output: %s', ME.message));
        end
    end

    %----------------------------------------------------------------------
    function openShutter(varargin)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to laser');
            return
        end
        if cb.Figure.UserData.DDGShotMode
            addLog('Blocked: In shot mode the shutter is controlled by DDG timing');
            return
        end

        handles = guihandles(cb.Figure);
        laser   = cb.Figure.UserData.Laser;

        addLog('Opening shutter...');

        try
            laser.ControlTheShutter(1);
            handles.ShutterStatus.Value     = 'OPEN';
            handles.ShutterStatus.FontColor = [0.80 0.15 0.05];
            cb.Figure.UserData.ShutterOpen  = true;
            updateUIState();
            addLog('Shutter opened  —  power control locked');
        catch ME
            addLog(sprintf('Error opening shutter: %s', ME.message));
        end
    end

    %----------------------------------------------------------------------
    function closeShutter(varargin)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to laser');
            return
        end
        if cb.Figure.UserData.DDGShotMode
            addLog('Blocked: In shot mode the shutter is controlled by DDG timing');
            return
        end

        handles = guihandles(cb.Figure);
        laser   = cb.Figure.UserData.Laser;

        addLog('Closing shutter...');

        try
            laser.ControlTheShutter(0);
            handles.ShutterStatus.Value     = 'CLOSED';
            handles.ShutterStatus.FontColor = [0.05 0.50 0.10];
            cb.Figure.UserData.ShutterOpen  = false;
            updateUIState();
            addLog('Shutter closed  —  power control unlocked');
        catch ME
            addLog(sprintf('Error closing shutter: %s', ME.message));
        end
    end

    %----------------------------------------------------------------------
    function queryShutterStatus(varargin)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to laser');
            return
        end

        handles = guihandles(cb.Figure);
        laser   = cb.Figure.UserData.Laser;

        addLog('Querying shutter status...');

        try
            status = laser.GetTheShutterStatus();

            if status == 1
                handles.ShutterStatus.Value     = 'OPEN';
                handles.ShutterStatus.FontColor = [0.80 0.15 0.05];
                cb.Figure.UserData.ShutterOpen  = true;
                updateUIState();
                addLog('Shutter status: OPEN  —  power control locked');
            elseif status == 0
                handles.ShutterStatus.Value     = 'CLOSED';
                handles.ShutterStatus.FontColor = [0.05 0.50 0.10];
                cb.Figure.UserData.ShutterOpen  = false;
                updateUIState();
                addLog('Shutter status: CLOSED');
            else
                handles.ShutterStatus.Value     = '--- Unknown ---';
                handles.ShutterStatus.FontColor = [0.40 0.40 0.40];
                addLog('Warning: Unexpected shutter response from laser');
            end

        catch ME
            addLog(sprintf('Error querying shutter: %s', ME.message));
        end
    end

    %----------------------------------------------------------------------
    function flashEtalon(varargin)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to laser');
            return
        end

        laser = cb.Figure.UserData.Laser;

        addLog('Flashing etalon (FLASH=1)...');

        try
            laser.FlashEtalon();
            addLog('Etalon flash complete');
        catch ME
            addLog(sprintf('Error flashing etalon: %s', ME.message));
        end
    end

    %----------------------------------------------------------------------
    function setEchoMode(varargin)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to laser');
            return
        end

        handles = guihandles(cb.Figure);
        laser   = cb.Figure.UserData.Laser;

        if contains(handles.EchoDropdown.Value, '1')
            echoVal = 1;
        else
            echoVal = 0;
        end

        addLog(sprintf('Setting echo mode to %d...', echoVal));

        try
            laser.ControlTheEcho(echoVal);
            addLog(sprintf('Echo mode set to %d', echoVal));
        catch ME
            addLog(sprintf('Error setting echo: %s', ME.message));
        end
    end

    %----------------------------------------------------------------------
    function addLog(message)
        handles    = guihandles(cb.Figure);
        currentLog = handles.ActivityLog.Value;
        timestamp  = datestr(now, 'HH:MM:SS');
        newEntry   = sprintf('[%s] %s', timestamp, message);

        if length(currentLog) > 100
            currentLog = currentLog(end-99:end);
        end

        handles.ActivityLog.Value = [currentLog; {newEntry}];
        drawnow;
    end

    %----------------------------------------------------------------------
    function closeGUI(varargin)
        if cb.Figure.UserData.Connected
            disconnectLaser();
        end
        delete(cb.Figure);
    end

end