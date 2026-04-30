function box = VISAR_PicomotorPanel(pico)
% VISAR_PicomotorPanel  Picomotor alignment GUI panel
%
% Replicates the legacy AlignCtrl panel (AlignCtrl.c / AlignCtrl.h) using
% the SLAM ComponentBox system. Adds a Connection section matching the
% pattern used in the Laser and DDG panels.
%
% Original panel controls (from AlignCtrl.h):
%   ALIGNPANEL_POS_D1A0..D2A1  - Position readouts (4 axes)
%   ALIGNPANEL_STEPSIZE        - Step size input
%   ALIGNPANEL_MOVED1A0..D2A1  - Positive move buttons (4 axes)
%   ALIGNPANEL_MOVED1A0_N..    - Negative move buttons (4 axes)
%   ALIGNPANEL_DEFINE_ZERO     - Reset all positions to zero
%   ALIGNPANEL_SELECT_SCOPE    - Scope selector (1-4)
%   ALIGNPANEL_SCOPEDDG        - Set scope and DDG for alignment
%   ALIGNPANEL_POINTS          - Acquisition points
%   ALIGNPANEL_CH1ON..CH4ON    - Channel select checkboxes
%   ALIGNPANEL_MONITOR_LIS     - Start continuous Lissajous acquisition
%   ALIGNPANEL_CONTINUOUS_LIS  - Stop and save Lissajous
%   ALIGNPANEL_SAVE_EXAMP      - Save example trace
%   ALIGNPANEL_PICO_STAT       - Status message display
%   ALIGNPANEL_ALIGN_DONE      - Close panel button
%
% Usage:
%   pico = Picomotor('10.2.2.209');   % connect hardware first
%   box  = VISAR_PicomotorPanel(pico);
%
%   box  = VISAR_PicomotorPanel();    % offline layout test
%
% Author: Seth
% Date:   2026

if nargin < 1
    pico = [];
end

import SLAM.Developer.ComponentBox

%% -----------------------------------------------------------------------
% Create the box
%------------------------------------------------------------------------
box = ComponentBox();
setName(box, 'Picomotor Alignment Control');
setFont(box, '', 11);

%% -----------------------------------------------------------------------
% GUI handle storage
%------------------------------------------------------------------------
gui = struct();

%% -----------------------------------------------------------------------
% CONNECTION SECTION
% Added to match Laser and DDG panel pattern.
% Unique to Picomotor: supports both TCP/IP and USB connection types.
%------------------------------------------------------------------------
hConnLabel = addMessage(box, 40, 1);
hConnLabel.Text = '--- Connection ---';
hConnLabel.FontWeight = 'bold';
newRow(box);

% Connection type dropdown (TCP/IP is the legacy/default mode)
gui.ConnType = addDropdown(box, 10);
gui.ConnType(1).Text = 'Type:';
gui.ConnType(2).Items = {'TCP/IP', 'USB'};
gui.ConnType(2).Value = 'TCP/IP';
gui.ConnType(2).Tag = 'ConnType';
newRow(box);

% IP Address input (TCP mode)
gui.IPAddress = addEdit(box, 20);
gui.IPAddress(1).Text = 'IP Address:';
gui.IPAddress(2).Value = '10.2.2.209';
gui.IPAddress(2).Tag = 'IPAddress';
newRow(box);

% Port (TCP mode)
gui.Port = addSpinner(box, 10);
gui.Port(1).Text = 'Port:';
gui.Port(2).Value = 23;
gui.Port(2).Limits = [1 65535];
gui.Port(2).Step = 1;
gui.Port(2).Tag = 'Port';
newRow(box);

% VISA resource string (USB mode)
gui.VISAResource = addEdit(box, 35);
gui.VISAResource(1).Text = 'VISA Resource:';
gui.VISAResource(2).Value = 'ASRL4::INSTR';
gui.VISAResource(2).Tag = 'VISAResource';
newRow(box);

% Connect / Disconnect buttons + status indicator
hBtnConnect = addButton(box, 10);
hBtnConnect.Text = 'Connect';
hBtnConnect.Tag  = 'BtnConnect';

hBtnDisconnect = addButton(box, 12);
hBtnDisconnect.Text = 'Disconnect';
hBtnDisconnect.Tag  = 'BtnDisconnect';

gui.ConnStatus = addMessage(box, 20, 1);
gui.ConnStatus.Tag = 'ConnStatus';
newRow(box);

% Set initial state based on whether hardware was passed in
if ~isempty(pico)
    gui.ConnStatus.Text = sprintf('Connected (%s)', pico.ConnectionType);
    gui.ConnStatus.FontColor = [0 0.55 0];
    hBtnConnect.Enable    = 'off';
    hBtnDisconnect.Enable = 'on';
else
    gui.ConnStatus.Text = 'Not Connected';
    gui.ConnStatus.FontColor = [0.75 0.3 0];
    hBtnConnect.Enable    = 'on';
    hBtnDisconnect.Enable = 'off';
end

%% -----------------------------------------------------------------------
% DRIVER 1 CONTROLS
%   Matches: ALIGNPANEL_MOVED1A0, ALIGNPANEL_MOVED1A0_N
%            ALIGNPANEL_MOVED1A1, ALIGNPANEL_MOVED1A1_N
%            ALIGNPANEL_POS_D1A0, ALIGNPANEL_POS_D1A1
%------------------------------------------------------------------------
hSep1 = addMessage(box, 40, 1);
hSep1.Text = repmat('-', 1, 40);
newRow(box);

hLabel1 = addMessage(box, 40, 1);
hLabel1.Text = '--- Driver 1 ---';
hLabel1.FontWeight = 'bold';
newRow(box);

% Axis 0
h = addMessage(box, 8, 1);
h.Text = 'Axis 0:';

hBtnD1A0P = addButton(box, 7);
hBtnD1A0P.Text = '+Move';

hBtnD1A0N = addButton(box, 7);
hBtnD1A0N.Text = '-Move';

h = addMessage(box, 9, 1);
h.Text = 'Position:';

gui.PosD1A0 = addSpinner(box, 8);
gui.PosD1A0(1).Text = '';
gui.PosD1A0(2).Value = 0;
gui.PosD1A0(2).Limits = [-1e6 1e6];
gui.PosD1A0(2).Step = 1;
gui.PosD1A0(2).Editable = 'off';
gui.PosD1A0(2).Tag = 'PosD1A0';

h = addMessage(box, 5, 1);
h.Text = 'steps';
newRow(box);

% Axis 1
h = addMessage(box, 8, 1);
h.Text = 'Axis 1:';

hBtnD1A1P = addButton(box, 7);
hBtnD1A1P.Text = '+Move';

hBtnD1A1N = addButton(box, 7);
hBtnD1A1N.Text = '-Move';

h = addMessage(box, 9, 1);
h.Text = 'Position:';

gui.PosD1A1 = addSpinner(box, 8);
gui.PosD1A1(1).Text = '';
gui.PosD1A1(2).Value = 0;
gui.PosD1A1(2).Limits = [-1e6 1e6];
gui.PosD1A1(2).Step = 1;
gui.PosD1A1(2).Editable = 'off';
gui.PosD1A1(2).Tag = 'PosD1A1';

h = addMessage(box, 5, 1);
h.Text = 'steps';
newRow(box);

%% -----------------------------------------------------------------------
% DRIVER 2 CONTROLS
%   Matches: ALIGNPANEL_MOVED2A0, ALIGNPANEL_MOVED2A0_N
%            ALIGNPANEL_MOVED2A1, ALIGNPANEL_MOVED2A1_N
%            ALIGNPANEL_POS_D2A0, ALIGNPANEL_POS_D2A1
%------------------------------------------------------------------------
hSep2 = addMessage(box, 40, 1);
hSep2.Text = repmat('-', 1, 40);
newRow(box);

hLabel2 = addMessage(box, 40, 1);
hLabel2.Text = '--- Driver 2 ---';
hLabel2.FontWeight = 'bold';
newRow(box);

% Axis 0
h = addMessage(box, 8, 1);
h.Text = 'Axis 0:';

hBtnD2A0P = addButton(box, 7);
hBtnD2A0P.Text = '+Move';

hBtnD2A0N = addButton(box, 7);
hBtnD2A0N.Text = '-Move';

h = addMessage(box, 9, 1);
h.Text = 'Position:';

gui.PosD2A0 = addSpinner(box, 8);
gui.PosD2A0(1).Text = '';
gui.PosD2A0(2).Value = 0;
gui.PosD2A0(2).Limits = [-1e6 1e6];
gui.PosD2A0(2).Step = 1;
gui.PosD2A0(2).Editable = 'off';
gui.PosD2A0(2).Tag = 'PosD2A0';

h = addMessage(box, 5, 1);
h.Text = 'steps';
newRow(box);

% Axis 1
h = addMessage(box, 8, 1);
h.Text = 'Axis 1:';

hBtnD2A1P = addButton(box, 7);
hBtnD2A1P.Text = '+Move';

hBtnD2A1N = addButton(box, 7);
hBtnD2A1N.Text = '-Move';

h = addMessage(box, 9, 1);
h.Text = 'Position:';

gui.PosD2A1 = addSpinner(box, 8);
gui.PosD2A1(1).Text = '';
gui.PosD2A1(2).Value = 0;
gui.PosD2A1(2).Limits = [-1e6 1e6];
gui.PosD2A1(2).Step = 1;
gui.PosD2A1(2).Editable = 'off';
gui.PosD2A1(2).Tag = 'PosD2A1';

h = addMessage(box, 5, 1);
h.Text = 'steps';
newRow(box);

%% -----------------------------------------------------------------------
% STEP SIZE + DEFINE ZERO
%   Matches: ALIGNPANEL_STEPSIZE, ALIGNPANEL_DEFINE_ZERO
%------------------------------------------------------------------------
hSep3 = addMessage(box, 40, 1);
hSep3.Text = repmat('-', 1, 40);
newRow(box);

gui.StepSize = addSpinner(box, 10);
gui.StepSize(1).Text = 'Step Size:';
gui.StepSize(2).Value = 1;
gui.StepSize(2).Limits = [1 10000];
gui.StepSize(2).Step = 1;
gui.StepSize(2).Tag = 'StepSize';

hBtnZero = addButton(box, 14);
hBtnZero.Text = 'Define Zero';
newRow(box);

%% -----------------------------------------------------------------------
% LISSAJOUS SECTION
%   Matches: ALIGNPANEL_SELECT_SCOPE, ALIGNPANEL_SCOPEDDG,
%            ALIGNPANEL_POINTS, ALIGNPANEL_CH1ON..CH4ON,
%            ALIGNPANEL_MONITOR_LIS, ALIGNPANEL_CONTINUOUS_LIS,
%            ALIGNPANEL_SAVE_EXAMP
%------------------------------------------------------------------------
hSep4 = addMessage(box, 40, 1);
hSep4.Text = repmat('-', 1, 40);
newRow(box);

hLisLabel = addMessage(box, 40, 1);
hLisLabel.Text = '--- Lissajous Alignment ---';
hLisLabel.FontWeight = 'bold';
newRow(box);

% Scope selector + Set Scope/DDG button
gui.ScopeSelect = addSpinner(box, 8);
gui.ScopeSelect(1).Text = 'Scope #:';
gui.ScopeSelect(2).Value = 1;
gui.ScopeSelect(2).Limits = [1 4];
gui.ScopeSelect(2).Step = 1;
gui.ScopeSelect(2).Tag = 'ScopeSelect';

hBtnScopeDDG = addButton(box, 18);
hBtnScopeDDG.Text = 'Set Scope && DDG';
newRow(box);

% Acquisition points
gui.AcqPoints = addSpinner(box, 10);
gui.AcqPoints(1).Text = 'Acq Points:';
gui.AcqPoints(2).Value = 500;
gui.AcqPoints(2).Limits = [100 100000];
gui.AcqPoints(2).Step = 100;
gui.AcqPoints(2).Tag = 'AcqPoints';
newRow(box);

% Channel select checkboxes (ALIGNPANEL_CH1ON..CH4ON)
h = addMessage(box, 10, 1);
h.Text = 'Channels:';

gui.Ch1On = addCheckbox(box);
gui.Ch1On.Text = 'CH1';
gui.Ch1On.Value = 1;
gui.Ch1On.Tag = 'Ch1On';

gui.Ch2On = addCheckbox(box);
gui.Ch2On.Text = 'CH2';
gui.Ch2On.Value = 1;
gui.Ch2On.Tag = 'Ch2On';

gui.Ch3On = addCheckbox(box);
gui.Ch3On.Text = 'CH3';
gui.Ch3On.Value = 1;
gui.Ch3On.Tag = 'Ch3On';

gui.Ch4On = addCheckbox(box);
gui.Ch4On.Text = 'CH4';
gui.Ch4On.Value = 1;
gui.Ch4On.Tag = 'Ch4On';
newRow(box);

% Monitor / Stop / Save buttons
hBtnMonitor = addButton(box, 18);
hBtnMonitor.Text = 'Monitor Lissajous';

hBtnStop = addButton(box, 16);
hBtnStop.Text = 'Stop && Save Lis';

hBtnSaveEx = addButton(box, 14);
hBtnSaveEx.Text = 'Save Example';
newRow(box);

%% -----------------------------------------------------------------------
% STATUS DISPLAY  (ALIGNPANEL_PICO_STAT)
%------------------------------------------------------------------------
hSep5 = addMessage(box, 40, 1);
hSep5.Text = repmat('-', 1, 40);
newRow(box);

gui.Status = addTextarea(box, 40, 3);
gui.Status(1).Text = 'Status:';
gui.Status(2).Value = 'Picomotor panel ready.';
gui.Status(2).Editable = 'off';
gui.Status(2).Tag = 'PicoStatus';
newRow(box);

%% -----------------------------------------------------------------------
% CLOSE BUTTON  (ALIGNPANEL_ALIGN_DONE)
%------------------------------------------------------------------------
hBtnDone = addButton(box, 16);
hBtnDone.Text = 'Alignment Done';

%% -----------------------------------------------------------------------
% Sync position displays from hardware if already connected
%------------------------------------------------------------------------
if ~isempty(pico)
    gui.PosD1A0(2).Value = pico.Position(1);
    gui.PosD1A1(2).Value = pico.Position(2);
    gui.PosD2A0(2).Value = pico.Position(3);
    gui.PosD2A1(2).Value = pico.Position(4);
end

%% -----------------------------------------------------------------------
% FINALIZE
%------------------------------------------------------------------------
fit(box);
locate(box);
show(box);

%% -----------------------------------------------------------------------
% ASSIGN CALLBACKS
%------------------------------------------------------------------------

% Connection
hBtnConnect.ButtonPushedFcn     = @ConnectPicomotor;
hBtnDisconnect.ButtonPushedFcn  = @DisconnectPicomotor;
gui.ConnType(2).ValueChangedFcn = @ConnectionTypeChanged;

% Move buttons - Driver 1
hBtnD1A0P.ButtonPushedFcn = @(~,~) MoveAxis(1, 0, +1);
hBtnD1A0N.ButtonPushedFcn = @(~,~) MoveAxis(1, 0, -1);
hBtnD1A1P.ButtonPushedFcn = @(~,~) MoveAxis(1, 1, +1);
hBtnD1A1N.ButtonPushedFcn = @(~,~) MoveAxis(1, 1, -1);

% Move buttons - Driver 2
hBtnD2A0P.ButtonPushedFcn = @(~,~) MoveAxis(2, 0, +1);
hBtnD2A0N.ButtonPushedFcn = @(~,~) MoveAxis(2, 0, -1);
hBtnD2A1P.ButtonPushedFcn = @(~,~) MoveAxis(2, 1, +1);
hBtnD2A1N.ButtonPushedFcn = @(~,~) MoveAxis(2, 1, -1);

% Other controls
hBtnZero.ButtonPushedFcn     = @DefineZero;
hBtnScopeDDG.ButtonPushedFcn = @SetScopeAndDDG;
hBtnMonitor.ButtonPushedFcn  = @MonitorLissajous;
hBtnStop.ButtonPushedFcn     = @StopAndSaveLissajous;
hBtnSaveEx.ButtonPushedFcn   = @SaveExample;
hBtnDone.ButtonPushedFcn     = @AlignmentDone;


%% =========================================================================
%  NESTED CALLBACK FUNCTIONS
% =========================================================================

    % ------------------------------------------------------------------
    % ConnectPicomotor
    %   Creates a new Picomotor object from the GUI connection settings.
    %   Matches the ConnectToTCPServer call in VISARctrl.c line 422.
    % ------------------------------------------------------------------
    function ConnectPicomotor(~, ~)
        connType = gui.ConnType(2).Value;
        SetStatus(sprintf('Connecting via %s...', connType));
        try
            if strcmp(connType, 'TCP/IP')
                ip   = gui.IPAddress(2).Value;
                port = gui.Port(2).Value;
                pico = Picomotor(ip, port);
            else
                resource = gui.VISAResource(2).Value;
                pico = Picomotor(resource);
            end
            gui.ConnStatus.Text = sprintf('Connected (%s)', pico.ConnectionType);
            gui.ConnStatus.FontColor = [0 0.55 0];
            hBtnConnect.Enable    = 'off';
            hBtnDisconnect.Enable = 'on';
            gui.PosD1A0(2).Value = pico.Position(1);
            gui.PosD1A1(2).Value = pico.Position(2);
            gui.PosD2A0(2).Value = pico.Position(3);
            gui.PosD2A1(2).Value = pico.Position(4);
            SetStatus(sprintf('Connected via %s. Default setup complete.', connType));
        catch ME
            gui.ConnStatus.Text = 'Connection Failed';
            gui.ConnStatus.FontColor = [0.8 0 0];
            SetStatus(sprintf('Connection Error: %s', ME.message));
        end
    end

    % ------------------------------------------------------------------
    % DisconnectPicomotor
    %   Turns off drivers and closes communication.
    %   Matches PicoDriveOff + DisconnectFromTCPServer in VISARctrl.c.
    % ------------------------------------------------------------------
    function DisconnectPicomotor(~, ~)
        if isempty(pico)
            SetStatus('Not connected.');
            return;
        end
        try
            pico.Disconnect();
            pico = [];
            gui.ConnStatus.Text = 'Not Connected';
            gui.ConnStatus.FontColor = [0.75 0.3 0];
            hBtnConnect.Enable    = 'on';
            hBtnDisconnect.Enable = 'off';
            SetStatus('Picomotor disconnected.');
        catch ME
            SetStatus(sprintf('Disconnect Error: %s', ME.message));
        end
    end

    % ------------------------------------------------------------------
    % ConnectionTypeChanged
    %   Shows/hides IP vs VISA resource fields based on selected type
    % ------------------------------------------------------------------
    function ConnectionTypeChanged(~, ~)
        connType = gui.ConnType(2).Value;
        if strcmp(connType, 'TCP/IP')
            gui.IPAddress(1).Visible    = 'on';
            gui.IPAddress(2).Visible    = 'on';
            gui.Port(1).Visible         = 'on';
            gui.Port(2).Visible         = 'on';
            gui.VISAResource(1).Visible = 'off';
            gui.VISAResource(2).Visible = 'off';
        else
            gui.IPAddress(1).Visible    = 'off';
            gui.IPAddress(2).Visible    = 'off';
            gui.Port(1).Visible         = 'off';
            gui.Port(2).Visible         = 'off';
            gui.VISAResource(1).Visible = 'on';
            gui.VISAResource(2).Visible = 'on';
        end
    end

    % ------------------------------------------------------------------
    % MoveAxis  Matches PicoMove() in AlignCtrl.c
    % ------------------------------------------------------------------
    function MoveAxis(drive, axis, direction)
        stepSize = gui.StepSize(2).Value * direction;
        if isempty(pico)
            SetStatus(sprintf('[Not connected] Move D%dA%d: %+d steps', drive, axis, stepSize));
            return;
        end
        SetStatus(sprintf('Moving Driver %d Axis %d: %+d steps...', drive, axis, stepSize));
        try
            pico.MoveRelative(drive, axis, stepSize);
            UpdatePositionDisplay(drive, axis, stepSize);
            SetStatus(sprintf('Move complete. D%dA%d = %d steps', ...
                drive, axis, GetPositionValue(drive, axis)));
        catch ME
            SetStatus(sprintf('Move Error: %s', ME.message));
        end
    end

    % ------------------------------------------------------------------
    % DefineZero  Matches DefineZeroCB in AlignCtrl.c
    % ------------------------------------------------------------------
    function DefineZero(~, ~)
        if ~isempty(pico)
            pico.DefineCurrentPositionAsZero();
        end
        gui.PosD1A0(2).Value = 0;
        gui.PosD1A1(2).Value = 0;
        gui.PosD2A0(2).Value = 0;
        gui.PosD2A1(2).Value = 0;
        SetStatus('All position counters reset to zero.');
    end

    % ------------------------------------------------------------------
    % SetScopeAndDDG  Matches SetScopeDDGCB in AlignCtrl.c
    %   Application logic deferred
    % ------------------------------------------------------------------
    function SetScopeAndDDG(~, ~)
        sn  = gui.ScopeSelect(2).Value;
        pts = gui.AcqPoints(2).Value;
        SetStatus(sprintf('Set Scope %d && DDG for alignment. Points = %d. (App logic pending)', sn, pts));
        fprintf('VISAR_PicomotorPanel: SetScopeAndDDG - Scope %d, %d points\n', sn, pts);
    end

    % ------------------------------------------------------------------
    % MonitorLissajous  Matches LisCB in AlignCtrl.c
    %   Application logic deferred
    % ------------------------------------------------------------------
    function MonitorLissajous(~, ~)
        sn = gui.ScopeSelect(2).Value;
        ch = [gui.Ch1On.Value, gui.Ch2On.Value, ...
              gui.Ch3On.Value, gui.Ch4On.Value];
        SetStatus(sprintf('Monitor Lissajous: Scope %d, CH[%d%d%d%d]. (App logic pending)', ...
            sn, ch(1), ch(2), ch(3), ch(4)));
        fprintf('VISAR_PicomotorPanel: MonitorLissajous - Scope %d, CH [%d %d %d %d]\n', ...
            sn, ch(1), ch(2), ch(3), ch(4));
    end

    % ------------------------------------------------------------------
    % StopAndSaveLissajous  Matches StopAndSaveLisCB in AlignCtrl.c
    % ------------------------------------------------------------------
    function StopAndSaveLissajous(~, ~)
        SetStatus('Lissajous acquisition stopped. (App logic pending)');
        fprintf('VISAR_PicomotorPanel: StopAndSaveLissajous called\n');
    end

    % ------------------------------------------------------------------
    % SaveExample  Matches SaveLisExampCB in AlignCtrl.c
    % ------------------------------------------------------------------
    function SaveExample(~, ~)
        SetStatus('Save example trace flagged. (App logic pending)');
        fprintf('VISAR_PicomotorPanel: SaveExample called\n');
    end

    % ------------------------------------------------------------------
    % AlignmentDone  Matches AlignDoneCB in AlignCtrl.c
    % ------------------------------------------------------------------
    function AlignmentDone(~, ~)
        SetStatus('Alignment done. Closing panel...');
        fprintf('VISAR_PicomotorPanel: Alignment done\n');
        pause(0.3);
        delete(box);
    end

    % ------------------------------------------------------------------
    % Helper: SetStatus
    % ------------------------------------------------------------------
    function SetStatus(msg)
        gui.Status(2).Value = msg;
        fprintf('PicomotorPanel: %s\n', msg);
    end

    % ------------------------------------------------------------------
    % Helper: UpdatePositionDisplay
    % ------------------------------------------------------------------
    function UpdatePositionDisplay(drive, axis, steps)
        switch drive * 10 + axis
            case 10,  gui.PosD1A0(2).Value = gui.PosD1A0(2).Value + steps;
            case 11,  gui.PosD1A1(2).Value = gui.PosD1A1(2).Value + steps;
            case 20,  gui.PosD2A0(2).Value = gui.PosD2A0(2).Value + steps;
            case 21,  gui.PosD2A1(2).Value = gui.PosD2A1(2).Value + steps;
        end
    end

    % ------------------------------------------------------------------
    % Helper: GetPositionValue
    % ------------------------------------------------------------------
    function val = GetPositionValue(drive, axis)
        switch drive * 10 + axis
            case 10,  val = gui.PosD1A0(2).Value;
            case 11,  val = gui.PosD1A1(2).Value;
            case 20,  val = gui.PosD2A0(2).Value;
            case 21,  val = gui.PosD2A1(2).Value;
            otherwise, val = 0;
        end
    end

end