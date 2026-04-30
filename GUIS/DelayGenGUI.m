function DG535_GUI()
% DG535_GUI Control interface for DG535 Digital Delay Generator with UI state management
%
% This GUI provides control of the DG535 delay generator with proper UI state
% management based on trigger mode and connection status, including Burst mode safety.

import SLAM.Developer.ComponentBox

cb = ComponentBox('hide');
setFont(cb,'Consolas')
setName(cb, 'DG535 Delay Generator Control');

h = addMessage(cb, 40, 1);
h.Text = 'DG535 Digital Delay Generator';
h.FontWeight = 'bold';
h.FontSize = 14;

newRow(cb);
h = addMessage(cb, 40, 1);
h.Text = 'Status: Not Connected';
h.Tag = 'StatusMsg';

newRow(cb);

% VISA Address input
h = addEdit(cb, 30);
h(1).Text = 'VISA Address:';
h(2).Value = 'GPIB0::15::INSTR';  % Default, change as needed
h(2).Tag = 'VisaAddress';

newRow(cb);

h = addButton(cb, 15);
h.Text = 'Connect';
h.Tag = 'ConnectBtn';
h.ButtonPushedFcn = @connectDG535;

h = addButton(cb, 15);
h.Text = 'Disconnect';
h.Tag = 'DisconnectBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @disconnectDG535;

newRow(cb);
newRow(cb);

h = addMessage(cb, 40, 1);
h.Text = '=== Trigger Settings ===';
h.FontWeight = 'bold';

newRow(cb);
h = addSpinner(cb, 25);
h(1).Text = 'Trigger Rate (Hz):';
h(2).Value = 100;
h(2).Limits = [0.001 1000];
h(2).Step = 1;
h(2).Tag = 'TrigRate';
h(2).Enable = 'off';
h(2).ValueChangedFcn = @setTriggerRate;

newRow(cb);
h = addDropdown(cb, 25);
h(1).Text = 'Trigger Mode:';
h(2).Items = {'Internal', 'External', 'SingleShot', 'Burst'};
h(2).Value = 'Internal';
h(2).Tag = 'TrigMode';
h(2).Enable = 'off';
h(2).ValueChangedFcn = @setTriggerMode;

newRow(cb);

% Add Single Shot button
h = addButton(cb, 20);
h.Text = 'Send Single Shot';
h.Tag = 'SingleShotBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @sendSingleShot;

newRow(cb);
newRow(cb);

h = addMessage(cb, 40, 1);
h.Text = '=== Delay Settings ===';
h.FontWeight = 'bold';

newRow(cb);

h = addMessage(cb, 50, 2);
h.Text = {'Channel format: DT channel,reference,delay', ...
          'Example: Ch A = DT 2,1,delay (A relative to T0)'};
h.FontSize = 10;

newRow(cb);

% Channel A (2) relative to T0 (1)
h = addSpinner(cb, 25);
h(1).Text = 'Channel A Delay (µs):';
h(2).Value = 0;
h(2).Limits = [0 1000];
h(2).Step = 1;
h(2).Tag = 'DelayA';
h(2).Enable = 'off';
h(2).ValueChangedFcn = @(src,~) setDelay(2, 1, src.Value);

newRow(cb);

% Channel B (3) relative to A (2)
h = addSpinner(cb, 25);
h(1).Text = 'Channel B Delay (µs):';
h(2).Value = 10;
h(2).Limits = [0 1000];
h(2).Step = 1;
h(2).Tag = 'DelayB';
h(2).Enable = 'off';
h(2).ValueChangedFcn = @(src,~) setDelay(3, 2, src.Value);

newRow(cb);

% Channel C (4) relative to T0 (1)
h = addSpinner(cb, 25);
h(1).Text = 'Channel C Delay (µs):';
h(2).Value = 0;
h(2).Limits = [0 1000];
h(2).Step = 1;
h(2).Tag = 'DelayC';
h(2).Enable = 'off';
h(2).ValueChangedFcn = @(src,~) setDelay(4, 1, src.Value);

newRow(cb);

% Channel D (5) relative to T0 (1)
h = addSpinner(cb, 25);
h(1).Text = 'Channel D Delay (µs):';
h(2).Value = 0;
h(2).Limits = [0 1000];
h(2).Step = 1;
h(2).Tag = 'DelayD';
h(2).Enable = 'off';
h(2).ValueChangedFcn = @(src,~) setDelay(5, 1, src.Value);

newRow(cb);
newRow(cb);

h = addMessage(cb, 40, 1);
h.Text = '=== Quick Actions ===';
h.FontWeight = 'bold';

newRow(cb);
h = addButton(cb, 15);
h.Text = 'Reset Delays';
h.Tag = 'ResetBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @resetDelays;

h = addButton(cb, 15);
h.Text = 'Clear Display';
h.Tag = 'ClearDispBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @clearDisplay;

newRow(cb);

h = addButton(cb, 15);
h.Text = 'Clear Instrument';
h.Tag = 'ClearInstBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @clearInstrument;

h = addButton(cb, 15);
h.Text = 'Write to Display';
h.Tag = 'WriteDispBtn';
h.Enable = 'off';
h.ButtonPushedFcn = @writeToDisplay;

newRow(cb);
newRow(cb);

h = addTextarea(cb, 50, 6);
h(1).Text = 'Activity Log:';
h(2).Value = {'DG535 GUI initialized', 'Ready to connect'};
h(2).Editable = 'off';
h(2).Tag = 'ActivityLog';

newRow(cb);
h = addButton(cb, 10);
h.Text = 'Close';
h.ButtonPushedFcn = @closeGUI;

fit(cb);
locate(cb);
show(cb);

% Store DG535 object in figure UserData
cb.Figure.UserData = struct('DG535', [], 'Connected', false, 'CurrentMode', 'NULL');

uiwait(cb.Figure);

%% Callback Functions

    function connectDG535(varargin)
        handles = guihandles(cb.Figure);
        
        try
            addLog('Attempting to connect to DG535...');
            
            visaAddress = handles.VisaAddress.Value;
            dg535 = DG535(visaAddress);
            
            % IMPORTANT: Increase timeout for Burst mode
            dg535.VisaObj.Timeout = 20;
            
            % Put device in safe mode immediately
            try
                dg535.SetTheTriggerRate(2); % SingleShot mode
                pause(0.2);
                addLog('Device set to SingleShot mode for safety');
            catch
                addLog('Warning: Could not set initial mode');
            end
            
            cb.Figure.UserData.DG535 = dg535;
            cb.Figure.UserData.Connected = true;
            cb.Figure.UserData.CurrentMode = 'SingleShot';
            
            handles.StatusMsg.Text = sprintf('Status: Connected (%s)', visaAddress);
            handles.StatusMsg.FontColor = [0 0.6 0];
            handles.ConnectBtn.Enable = 'off';
            handles.DisconnectBtn.Enable = 'on';
            handles.VisaAddress.Editable = 'off';
            
            % Set dropdown to match
            handles.TrigMode.Value = 'SingleShot';
            
            updateUIState();
            
            addLog(sprintf('Successfully connected to %s', visaAddress));
            addLog('NOTE: Device starts in SingleShot mode to prevent busy-state issues');
            
        catch ME
            addLog(sprintf('Connection failed: %s', ME.message));
            cb.Figure.UserData.DG535 = [];
            cb.Figure.UserData.Connected = false;
        end
    end

    function disconnectDG535(varargin)
        handles = guihandles(cb.Figure);
        
        try
            % Clear connection
            if ~isempty(cb.Figure.UserData.DG535)
                dg535 = cb.Figure.UserData.DG535;
                
                % Try to write disconnect message, but don't error if it fails
                try
                    dg535.WriteStringToDisplayOnDDG('GUI Disconnected');
                catch
                    % Ignore display errors during disconnect
                end
                
                % Clean up VISA object
                try
                    delete(dg535.VisaObj);
                catch
                    % Ignore cleanup errors
                end
            end
            
            cb.Figure.UserData.Connected = false;
            cb.Figure.UserData.DG535 = [];
            cb.Figure.UserData.CurrentMode = 'NULL';
            
            % Update UI
            handles.StatusMsg.Text = 'Status: Not Connected';
            handles.StatusMsg.FontColor = [0 0 0]; % Black
            handles.ConnectBtn.Enable = 'on';
            handles.DisconnectBtn.Enable = 'off';
            handles.VisaAddress.Editable = 'on';
            
            % Disable all controls
            updateUIState();
            
            addLog('Disconnected from DG535');
            
        catch ME
            addLog(sprintf('Disconnect error: %s', ME.message));
        end
    end

    function updateUIState()
        % Update UI element enable/disable states based on connection and mode
        handles = guihandles(cb.Figure);
        
        isConnected = cb.Figure.UserData.Connected;
        currentMode = cb.Figure.UserData.CurrentMode;
        
        if ~isConnected
            % Disable everything when not connected
            handles.TrigRate.Enable = 'off';
            handles.TrigMode.Enable = 'off';
            handles.SingleShotBtn.Enable = 'off';
            handles.DelayA.Enable = 'off';
            handles.DelayB.Enable = 'off';
            handles.DelayC.Enable = 'off';
            handles.DelayD.Enable = 'off';
            handles.ResetBtn.Enable = 'off';
            handles.ClearDispBtn.Enable = 'off';
            handles.ClearInstBtn.Enable = 'off';
            handles.WriteDispBtn.Enable = 'off';
        else
            % Connected - enable based on mode
            handles.TrigMode.Enable = 'on';  % Always can change mode
            
            % Always enable delay controls when connected
            handles.DelayA.Enable = 'on';
            handles.DelayB.Enable = 'on';
            handles.DelayC.Enable = 'on';
            handles.DelayD.Enable = 'on';
            handles.ResetBtn.Enable = 'on';
            handles.ClearDispBtn.Enable = 'on';
            handles.ClearInstBtn.Enable = 'on';
            handles.WriteDispBtn.Enable = 'on';
            
            % Mode-specific enables
            switch currentMode
                case 'Internal'
                    handles.TrigRate.Enable = 'on';
                    handles.SingleShotBtn.Enable = 'off';
                    
                case 'External'
                    handles.TrigRate.Enable = 'off';  % External trigger sets rate
                    handles.SingleShotBtn.Enable = 'off';
                    
                case 'SingleShot'
                    handles.TrigRate.Enable = 'off';  % Manual trigger only
                    handles.SingleShotBtn.Enable = 'on';
                    
                case 'Burst'
                    handles.TrigRate.Enable = 'on';
                    handles.SingleShotBtn.Enable = 'off';
                    addLog('NOTE: In Burst mode, operations auto-switch to SingleShot temporarily');
                    
                otherwise % 'NULL' or unknown
                    % Default to internal-like behavior
                    handles.TrigRate.Enable = 'on';
                    handles.SingleShotBtn.Enable = 'off';
            end
        end
    end

    function setTriggerRate(src, ~)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to device');
            return;
        end
        
        rate = src.Value;
        addLog(sprintf('Setting trigger rate to %.3f Hz', rate));
        
        try
            dg535 = cb.Figure.UserData.DG535;
            dg535.InputTrigerRate(rate);
            addLog('Trigger rate set successfully');
            
        catch ME
            addLog(sprintf('Error setting trigger rate: %s', ME.message));
        end
    end

    function setTriggerMode(src, ~)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to device');
            return;
        end
        
        mode = src.Value;
        addLog(sprintf('Setting trigger mode to: %s', mode));
        
        try
            dg535 = cb.Figure.UserData.DG535;
            
            % Map mode string to numeric value for your class
            switch mode
                case 'Internal'
                    modeNum = 0;
                case 'External'
                    modeNum = 1;
                case 'SingleShot'
                    modeNum = 2;
                case 'Burst'
                    modeNum = 3;
                otherwise
                    modeNum = 0;
            end
            
            dg535.SetTheTriggerRate(modeNum);
            
            % Update stored mode and UI state
            cb.Figure.UserData.CurrentMode = mode;
            updateUIState();
            
            addLog('Trigger mode set successfully');
            
        catch ME
            addLog(sprintf('Error setting trigger mode: %s', ME.message));
        end
    end

    function sendSingleShot(varargin)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to device');
            return;
        end
        
        try
            dg535 = cb.Figure.UserData.DG535;
            
            % Check if in SingleShot mode
            if dg535.CurrentTriggerMode == "SingleShot"
                dg535.SendSingleShotTriggerRate();
                addLog('Single shot trigger sent');
            else
                addLog('Error: Must be in SingleShot mode to send single shot');
                addLog(sprintf('Current mode: %s', dg535.CurrentTriggerMode));
            end
            
        catch ME
            addLog(sprintf('Error sending single shot: %s', ME.message));
        end
    end

    function setDelay(channel, reference, delayUs)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to device');
            return;
        end
        
        % Convert µs to seconds for the DG535 command
        delaySeconds = delayUs * 1e-6;
        
        % Map channel numbers to names for logging
        channelNames = {'T0', 'A', 'B', 'C', 'D'};
        if channel >= 2 && channel <= 5
            chanName = channelNames{channel};
        else
            chanName = num2str(channel);
        end
        
        if reference >= 1 && reference <= 5
            refName = channelNames{reference};
        else
            refName = num2str(reference);
        end
        
        addLog(sprintf('Setting Channel %s (ref: %s) delay to %.1f µs', ...
                       chanName, refName, delayUs));
        
        try
            dg535 = cb.Figure.UserData.DG535;
            
            % If in Burst mode, temporarily switch to SingleShot
            needsRestore = false;
            if strcmp(cb.Figure.UserData.CurrentMode, 'Burst')
                previousMode = dg535.EnterConfigMode();
                needsRestore = true;
            end
            
            dg535.DelayTimeOfChannel(channel, reference, delaySeconds);
            addLog(sprintf('Channel %s delay set successfully', chanName));
            
            % Restore mode if needed
            if needsRestore
                dg535.ExitConfigMode(previousMode);
            end
            
        catch ME
            addLog(sprintf('Error setting delay: %s', ME.message));
        end
    end

    function resetDelays(varargin)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to device');
            return;
        end
        
        handles = guihandles(cb.Figure);
        dg535 = cb.Figure.UserData.DG535;
        
        try
            % 1. Switch to safe mode and stop high-speed triggering
            previousMode = dg535.EnterConfigMode();
            addLog('Entering safe configuration mode');
            
            % 2. Use the factory 'CL' command to zero all delays simultaneously
            % This prevents the "Range Err" caused by staggered channel updates
            dg535.ClearInstrument();
            pause(0.5); % Give the internal processor time to reset the hardware
            
            % 3. Synchronize GUI spinners
            handles.DelayA.Value = 0;
            handles.DelayB.Value = 0;
            handles.DelayC.Value = 0;
            handles.DelayD.Value = 0;
            
            addLog('Reset all delays to 0 (All referenced to T0)');
            
            % 4. Resume original trigger mode
            dg535.ExitConfigMode(previousMode);
            addLog(sprintf('Restored mode: %s', previousMode));
            
        catch ME
            addLog(sprintf('Reset failed: %s', ME.message));
        end
    end

    function clearDisplay(varargin)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to device');
            return;
        end
        
        dg535 = cb.Figure.UserData.DG535;
        
        try
            % Enter safe mode if in Burst
            needsRestore = false;
            if strcmp(cb.Figure.UserData.CurrentMode, 'Burst')
                previousMode = dg535.EnterConfigMode();
                needsRestore = true;
                addLog('Temporarily switched to SingleShot for display clear');
            end
            
            dg535.ClearStringsFromDispaly();
            addLog('Display cleared');
            
            % Restore mode if needed
            if needsRestore
                dg535.ExitConfigMode(previousMode);
                addLog('Restored Burst mode');
            end
            
        catch ME
            addLog(sprintf('Error: %s', ME.message));
        end
    end

    function clearInstrument(varargin)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to device');
            return;
        end
        
        try
            answer = questdlg('This will clear all settings on the DG535. Continue?', ...
                             'Confirm Clear', 'Yes', 'No', 'No');
            
            if strcmp(answer, 'Yes')
                dg535 = cb.Figure.UserData.DG535;
                
                % Always enter safe mode for instrument clear
                previousMode = dg535.EnterConfigMode();
                addLog('Entered safe mode for instrument reset');
                
                dg535.ClearInstrument();
                addLog('Instrument Reset');
                
                % Device is now in unknown state - set to SingleShot
                cb.Figure.UserData.CurrentMode = 'SingleShot';
                handles = guihandles(cb.Figure);
                handles.TrigMode.Value = 'SingleShot';
                updateUIState();
                
                addLog('Device set to SingleShot mode after reset');
            else
                addLog('Instrument reset cancelled');
            end
            
        catch ME
            addLog(sprintf('Error: %s', ME.message));
        end
    end

    function writeToDisplay(varargin)
        if ~cb.Figure.UserData.Connected
            addLog('Error: Not connected to device');
            return;
        end
        
        dg535 = cb.Figure.UserData.DG535;
        
        try
            message = inputdlg('Enter message to display on DG535:', ...
                              'Write to Display', 1, {'Hello from GUI'});
            
            if ~isempty(message)
                % Enter safe mode if in Burst
                needsRestore = false;
                if strcmp(cb.Figure.UserData.CurrentMode, 'Burst')
                    previousMode = dg535.EnterConfigMode();
                    needsRestore = true;
                end
                
                dg535.WriteStringToDisplayOnDDG(message{1});
                addLog(sprintf('Displayed: %s', message{1}));
                
                % Restore mode if needed
                if needsRestore
                    dg535.ExitConfigMode(previousMode);
                end
            end
            
        catch ME
            addLog(sprintf('Error: %s', ME.message));
        end
    end

    function addLog(message)
        handles = guihandles(cb.Figure);
        currentLog = handles.ActivityLog.Value;
        timestamp = datestr(now, 'HH:MM:SS');
        newEntry = sprintf('[%s] %s', timestamp, message);
        
        % Keep log to last 100 entries
        if length(currentLog) > 100
            currentLog = currentLog(end-99:end);
        end
        
        handles.ActivityLog.Value = [currentLog; {newEntry}];
        
        % Scroll to bottom
        drawnow;
    end

    function closeGUI(varargin)
        % Disconnect if connected
        if cb.Figure.UserData.Connected
            disconnectDG535();
        end
        delete(cb.Figure);
    end

end