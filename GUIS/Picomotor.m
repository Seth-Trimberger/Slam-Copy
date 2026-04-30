classdef Picomotor
    % Picomotor - Control class for New Focus Picomotor Controller 8742
    %
    % Supports two connection modes:
    %   TCP/IP  - Ethernet connection (legacy system mode, port 23)
    %   USB     - USB-to-DB9 serial connection via MATLAB visadev
    %
    % The legacy VISAR system used TCP/IP exclusively. USB-serial support
    % is added here to match the 8742 controller's full interface options.
    %
    % Commands are derived from the original C implementation (AlignCtrl.c,
    % TCPio.c) and the New Focus 8742 command reference.
    %
    % Default setup (matching PicoDefaultSetup in TCPio.c):
    %   - Both drivers ON
    %   - Both drivers set to Axis 0
    %   - All axes set to velocity 100 steps/sec
    %
    % Usage (TCP/IP):
    %   pico = Picomotor('10.2.2.209');
    %   pico = Picomotor('10.2.2.194');         % dual-driver unit
    %
    % Usage (USB/serial via VISA):
    %   pico = Picomotor('ASRL4::INSTR');   % COM4 serial port
    %
    % Author: Seth
    % Date:   2026

    properties
        % Connection
        ConnectionType  % 'TCP' or 'USB'
        IPAddress       % IP address string (TCP only)
        Port            % TCP port number (TCP only)
        ResourceName    % VISA resource string (USB only)

        % Communication objects
        TCPObj          % tcpclient object (TCP mode)
        VISAObj         % visadev object (USB mode)

        % Motor state (mirrors C globals: driverOn[], activeAxis[], picoPos[])
        DriverOn        % [1x2] logical - is each driver powered on
        ActiveAxis      % [1x2] int     - currently selected axis per driver (0 or 1)
        Position        % [1x4] int     - cumulative step position [D1A0 D1A1 D2A0 D2A1]

        % Default velocity applied during DefaultSetup
        DefaultVelocity = 100   % steps/sec, matches legacy C value
    end

    methods

        %------------------------------------------------------------------
        function obj = Picomotor(AddressInput, PortOrResourceInput)
            % Picomotor  Constructor - connect via TCP/IP or USB/VISA
            %
            % TCP/IP call:
            %   obj = Picomotor('10.2.2.209')          % uses default port 23
            %   obj = Picomotor('10.2.2.209', 23)
            %
            % USB/VISA call:
            %   obj = Picomotor('ASRL4::INSTR')        % COM4 serial port
            %
            % No-argument call (object only, no connection):
            %   obj = Picomotor()

            % Initialize state arrays (matches C globals)
            obj.DriverOn   = [false false];
            obj.ActiveAxis = [0 0];
            obj.Position   = [0 0 0 0];

            % Return unconnected object if no address provided
            if nargin < 1 || isempty(AddressInput)
                fprintf('Picomotor object created. Call constructor with address to connect.\n');
                return;
            end

            % Determine connection type from address format
            if startsWith(AddressInput, 'USB') || startsWith(AddressInput, 'ASRL') || ...
               startsWith(AddressInput, 'GPIB') || contains(AddressInput, '::')
                % --- USB / VISA mode ---
                obj.ConnectionType = 'USB';
                obj.ResourceName   = AddressInput;

                fprintf('Connecting to Picomotor via USB/VISA: %s\n', obj.ResourceName);
                obj.VISAObj = visadev(obj.ResourceName);
                obj.VISAObj.BaudRate    = 19200;
                obj.VISAObj.DataBits    = 8;
                obj.VISAObj.StopBits    = 1;
                obj.VISAObj.Parity      = 'none';
                obj.VISAObj.FlowControl = 'none';
                obj.VISAObj.Timeout     = 5;
                obj.VISAObj.configureTerminator("LF");

                pause(0.2);
                flush(obj.VISAObj);   % Clear any startup bytes (visadev: flush always safe)

                fprintf('Picomotor Connected via USB at %s\n', obj.ResourceName);

            else
                % --- TCP/IP mode (legacy) ---
                obj.ConnectionType = 'TCP';
                obj.IPAddress      = AddressInput;

                if nargin < 2
                    obj.Port = 23;   % default Telnet port used by 8742
                else
                    obj.Port = PortOrResourceInput;
                end

                fprintf('Connecting to Picomotor via TCP/IP: %s:%d\n', ...
                        obj.IPAddress, obj.Port);
                obj.TCPObj = tcpclient(obj.IPAddress, obj.Port);
                obj.TCPObj.Timeout = 5;

                pause(0.2);
                if obj.TCPObj.NumBytesAvailable > 0
                    flush(obj.TCPObj);
                end

                fprintf('Picomotor Connected via TCP/IP at %s:%d\n', ...
                        obj.IPAddress, obj.Port);
            end

            % Run default setup to match legacy PicoDefaultSetup behavior
            obj.DefaultSetup();
        end

        %------------------------------------------------------------------
        function DefaultSetup(obj)
            % DefaultSetup  Replicates PicoDefaultSetup from TCPio.c
            %
            % Sends the same 8-command initialization sequence:
            %   MON 1, CHL 1=0, VEL 1 0=100, VEL 1 1=100
            %   MON 2, CHL 2=0, VEL 2 0=100, VEL 2 1=100

            fprintf('Running Picomotor Default Setup\n');

            commands = { ...
                sprintf('MON 1'),      ...  % motor driver 1 on
                sprintf('CHL 1=0'),    ...  % driver 1 -> axis 0
                sprintf('VEL 1 0=%d', obj.DefaultVelocity), ...  % D1 A0 velocity
                sprintf('VEL 1 1=%d', obj.DefaultVelocity), ...  % D1 A1 velocity
                sprintf('MON 2'),      ...  % motor driver 2 on
                sprintf('CHL 2=0'),    ...  % driver 2 -> axis 0
                sprintf('VEL 2 0=%d', obj.DefaultVelocity), ...  % D2 A0 velocity
                sprintf('VEL 2 1=%d', obj.DefaultVelocity)  ...  % D2 A1 velocity
            };

            for i = 1:numel(commands)
                obj.SendTheCommand(commands{i});
            end

            % Update internal state to match what we sent
            obj.DriverOn   = [true true];
            obj.ActiveAxis = [0 0];

            fprintf('Picomotor Default Setup Complete\n');
        end

        %------------------------------------------------------------------
        function TurnOnTheMotorDriver(obj, DriveInput)
            % TurnOnTheMotorDriver  Power on a motor driver (MON command)
            %
            % Matches C: sprintf(cmdStr,"MON %d\n", drive)
            %
            % DriveInput: 1 or 2

            fprintf('Turning On Motor Driver %d\n', DriveInput);

            if ~obj.ValidateDrive(DriveInput)
                return;
            end

            obj.SendTheCommand(sprintf('MON %d', DriveInput));
            obj.DriverOn(DriveInput) = true;
            fprintf('Motor Driver %d Is Now On\n', DriveInput);
        end

        %------------------------------------------------------------------
        function TurnOffTheMotorDriver(obj, DriveInput)
            % TurnOffTheMotorDriver  Power off a motor driver (MOF command)
            %
            % Matches C: sprintf(cmdStr,"MOF %d\n", drive)
            % Called by PicoDriveOff() in legacy system before disconnect.
            %
            % DriveInput: 1 or 2

            fprintf('Turning Off Motor Driver %d\n', DriveInput);

            if ~obj.ValidateDrive(DriveInput)
                return;
            end

            if ~obj.DriverOn(DriveInput)
                fprintf('Motor Driver %d Is Already Off\n', DriveInput);
                return;
            end

            obj.SendTheCommand(sprintf('MOF %d', DriveInput));
            obj.DriverOn(DriveInput) = false;
            fprintf('Motor Driver %d Is Now Off\n', DriveInput);
        end

        %------------------------------------------------------------------
        function SelectTheAxis(obj, DriveInput, AxisInput)
            % SelectTheAxis  Set the active channel/axis for a driver (CHL command)
            %
            % Matches C: sprintf(cmdStr,"CHL %d=%d\n", drive, axis)
            %
            % DriveInput: 1 or 2
            % AxisInput:  0 or 1

            fprintf('Selecting Axis %d On Driver %d\n', AxisInput, DriveInput);

            if ~obj.ValidateDrive(DriveInput) || ~obj.ValidateAxis(AxisInput)
                return;
            end

            obj.SendTheCommand(sprintf('CHL %d=%d', DriveInput, AxisInput));
            obj.ActiveAxis(DriveInput) = AxisInput;
            fprintf('Axis %d Selected On Driver %d\n', AxisInput, DriveInput);
        end

        %------------------------------------------------------------------
        function SetTheVelocity(obj, DriveInput, AxisInput, VelocityInput)
            % SetTheVelocity  Set step velocity for a specific axis (VEL command)
            %
            % Matches C: sprintf(cmdStr,"VEL %d %d=%d\n", drive, axis, velocity)
            %
            % DriveInput:    1 or 2
            % AxisInput:     0 or 1
            % VelocityInput: integer steps/sec (0 to 2000 for 8742)

            fprintf('Setting Velocity For Driver %d Axis %d\n', DriveInput, AxisInput);

            if ~obj.ValidateDrive(DriveInput) || ~obj.ValidateAxis(AxisInput)
                return;
            end
            if ~isnumeric(VelocityInput) || VelocityInput < 0 || VelocityInput > 2000
                fprintf('Error: Velocity Must Be Numeric Between 0 And 2000\n');
                return;
            end

            obj.SendTheCommand(sprintf('VEL %d %d=%d', DriveInput, AxisInput, round(VelocityInput)));
            fprintf('Velocity Set To %d Steps/Sec For Driver %d Axis %d\n', ...
                    round(VelocityInput), DriveInput, AxisInput);
        end

        %------------------------------------------------------------------
        function SetTheRelativeMoveDistance(obj, DriveInput, StepsInput)
            % SetTheRelativeMoveDistance  Set relative move in steps (REL command)
            %
            % Matches C: sprintf(cmdStr,"REL %d=%d\n", drive, picoStep)
            % Sign of StepsInput determines direction.
            %
            % DriveInput: 1 or 2
            % StepsInput: signed integer (negative = reverse direction)

            fprintf('Setting Relative Move Distance For Driver %d\n', DriveInput);

            if ~obj.ValidateDrive(DriveInput)
                return;
            end
            if ~isnumeric(StepsInput)
                fprintf('Error: Steps Must Be Numeric\n');
                return;
            end

            obj.SendTheCommand(sprintf('REL %d=%d', DriveInput, round(StepsInput)));
            fprintf('Relative Move Set To %d Steps For Driver %d\n', ...
                    round(StepsInput), DriveInput);
        end

        %------------------------------------------------------------------
        function ExecuteTheMove(obj, DriveInput)
            % ExecuteTheMove  Trigger the move (GO command)
            %
            % Matches C: sprintf(cmdStr,"GO %d\n", drive)
            % Must be preceded by SelectTheAxis and SetTheRelativeMoveDistance.
            %
            % DriveInput: 1 or 2

            fprintf('Executing Move On Driver %d\n', DriveInput);

            if ~obj.ValidateDrive(DriveInput)
                return;
            end

            obj.SendTheCommand(sprintf('GO %d', DriveInput));
            fprintf('Move Executed On Driver %d\n', DriveInput);
        end

        %------------------------------------------------------------------
        function MoveRelative(obj, DriveInput, AxisInput, StepsInput)
            % MoveRelative  Full move sequence: select axis, set distance, execute
            %
            % Replicates the PicoMove() sequence from AlignCtrl.c:
            %   1. MON (if driver not already on)
            %   2. CHL - select axis
            %   3. REL - set relative move distance
            %   4. GO  - execute
            %
            % Also updates the cumulative Position array.
            %
            % DriveInput: 1 or 2
            % AxisInput:  0 or 1
            % StepsInput: signed integer (negative = reverse)

            fprintf('Running Move Sequence: Driver %d, Axis %d, Steps %d\n', ...
                    DriveInput, AxisInput, StepsInput);

            if ~obj.ValidateDrive(DriveInput) || ~obj.ValidateAxis(AxisInput)
                return;
            end
            if ~isnumeric(StepsInput)
                fprintf('Error: Steps Must Be Numeric\n');
                return;
            end

            % Turn on driver if not already on (matches C driverOn[] check)
            if ~obj.DriverOn(DriveInput)
                obj.TurnOnTheMotorDriver(DriveInput);
                pause(0.1);
            end

            obj.SelectTheAxis(DriveInput, AxisInput);
            pause(0.1);
            obj.SetTheRelativeMoveDistance(DriveInput, round(StepsInput));
            pause(0.1);
            obj.ExecuteTheMove(DriveInput);

            % Update cumulative position (matches C: picoPos[axisN] += picoStep)
            % axisN = 2*(drive-1) + axis  =>  D1A0=0, D1A1=1, D2A0=2, D2A1=3
            axisIndex = 2*(DriveInput - 1) + AxisInput + 1;  % 1-based for MATLAB
            obj.Position(axisIndex) = obj.Position(axisInd[piex) + round(StepsInput);

            fprintf('Move Complete. Position[D%dA%d] = %d steps\n', ...
                    DriveInput, AxisInput, obj.Position(axisIndex));
        end

        %------------------------------------------------------------------
        function DefineCurrentPositionAsZero(obj)
            % DefineCurrentPositionAsZero  Reset all position counters to zero
            %
            % Matches C: DefineZeroCB - sets picoPos[0..3] = 0
            % This is a software-only reset; no command sent to hardware.

            obj.Position = [0 0 0 0];
            fprintf('Picomotor Position Counters Reset To Zero\n');
        end

        %------------------------------------------------------------------
        function StopTheMove(obj, DriveInput)
            % StopTheMove  Abort an in-progress move (ST command)
            %
            % DriveInput: 1 or 2 (or omit to stop both)

            if nargin < 2
                fprintf('Stopping All Drivers\n');
                obj.SendTheCommand('ST');
            else
                if ~obj.ValidateDrive(DriveInput)
                    return;
                end
                fprintf('Stopping Driver %d\n', DriveInput);
                obj.SendTheCommand(sprintf('ST %d', DriveInput));
            end
        end

        %------------------------------------------------------------------
        function DisplayTheStatus(obj)
            % DisplayTheStatus  Print connection info and current motor state

            fprintf('\n--- Picomotor Status ---\n');
            fprintf('Connection Type : %s\n', obj.ConnectionType);
            if strcmp(obj.ConnectionType, 'TCP')
                fprintf('IP Address      : %s:%d\n', obj.IPAddress, obj.Port);
            else
                fprintf('VISA Resource   : %s\n', obj.ResourceName);
            end
            fprintf('Default Velocity: %d steps/sec\n', obj.DefaultVelocity);
            fprintf('Driver 1 On     : %d\n', obj.DriverOn(1));
            fprintf('Driver 2 On     : %d\n', obj.DriverOn(2));
            fprintf('Active Axis D1  : %d\n', obj.ActiveAxis(1));
            fprintf('Active Axis D2  : %d\n', obj.ActiveAxis(2));
            fprintf('Position D1A0   : %d steps\n', obj.Position(1));
            fprintf('Position D1A1   : %d steps\n', obj.Position(2));
            fprintf('Position D2A0   : %d steps\n', obj.Position(3));
            fprintf('Position D2A1   : %d steps\n', obj.Position(4));
            fprintf('------------------------\n\n');
        end

        %------------------------------------------------------------------
        function Disconnect(obj)
            % Disconnect  Turn off drivers and close the connection
            %
            % Matches C: PicoDriveOff(1), PicoDriveOff(2), then
            %            DisconnectFromTCPServer(picom.hconversation)

            fprintf('Disconnecting Picomotor\n');

            % Turn off both drivers (matches legacy shutdown sequence)
            obj.TurnOffTheMotorDriver(1);
            obj.TurnOffTheMotorDriver(2);

            % Close communication object
            if strcmp(obj.ConnectionType, 'TCP')
                if ~isempty(obj.TCPObj)
                    clear obj.TCPObj;
                end
            else
                if ~isempty(obj.VISAObj)
                    clear obj.VISAObj;
                end
            end

            fprintf('Picomotor Disconnected\n');
        end

    end

    % =====================================================================
    % Private helper methods
    % =====================================================================
    methods (Access = private)

        function SendTheCommand(obj, CommandString)
            % SendTheCommand  Write a command to the controller
            %
            % The 8742 controller expects commands terminated with newline.
            % In TCP mode: writeline appends the terminator.
            % In USB mode: writeline uses the Terminator property (default LF).

            try
                if strcmp(obj.ConnectionType, 'TCP')
                    writeline(obj.TCPObj, CommandString);
                    pause(0.05);
                    if obj.TCPObj.NumBytesAvailable > 0
                        flush(obj.TCPObj);
                    end
                else
                    writeline(obj.VISAObj, CommandString);
                    pause(0.05);
                    flush(obj.VISAObj);   % visadev: flush always safe, no NumBytesAvailable
                end
            catch ME
                fprintf('Error Sending Command "%s": %s\n', CommandString, ME.message);
            end
        end

        function isValid = ValidateDrive(~, DriveInput)
            % ValidateDrive  Check drive number is 1 or 2
            isValid = isnumeric(DriveInput) && isscalar(DriveInput) && ...
                      (DriveInput == 1 || DriveInput == 2);
            if ~isValid
                fprintf('Error: Drive Must Be 1 Or 2\n');
            end
        end

        function isValid = ValidateAxis(~, AxisInput)
            % ValidateAxis  Check axis number is 0 or 1
            isValid = isnumeric(AxisInput) && isscalar(AxisInput) && ...
                      (AxisInput == 0 || AxisInput == 1);
            if ~isValid
                fprintf('Error: Axis Must Be 0 Or 1\n');
            end
        end

    end
end