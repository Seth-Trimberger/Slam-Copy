classdef DAQUSB6009 < handle
    % DAQ_USB6009  NI USB-6009/6501 digital output controller for VISAR beam paddles.
    %
    % The DAQ drives two optical beam-blocking solenoids (paddles) in the
    % VISAR interferometer:
    %
    %   Line 0 (value 1) = PZT leg paddle
    %   Line 1 (value 2) = Etalon leg paddle
    %
    % This maps directly to the legacy C DAQdigOut() calls:
    %   DAQdigOut(panel, 0)  ->  both legs unblocked
    %   DAQdigOut(panel, 1)  ->  PZT leg blocked
    %   DAQdigOut(panel, 2)  ->  Etalon leg blocked
    %   DAQdigOut(panel, 3)  ->  both legs blocked
    %
    % IMPORTANT — NI USB-6009 DAQ Toolbox constraints:
    %   - All 8 lines on the port must be added (port0/line0:7).
    %     Adding only a subset (e.g. line0:1) causes write() to
    %     silently fail with no error.
    %   - write() expects an 8-element numeric row vector, one
    %     element per line in line-number order [line0 .. line7].
    %   - NI MAX test panels hold an exclusive device lock; close
    %     MAX before using this class.
    %
    % Usage:
    %   DAQUSB6009.listDevices()
    %   daq = DAQUSB6009('Dev3');
    %   daq.setSolenoid('pzt', true);        % block PZT leg
    %   daq.setSolenoid('etalon', false);    % unblock Etalon leg
    %   daq.blockPZT();                      % convenience wrapper
   
    %This one works
    %   daq.blockEtalon();
    %   daq.unblockAll();
    %   daq.blockAll();
    %   s = daq.getState();                  % struct with .pzt and .etalon fields
    %   delete(daq);
    %
    % Bit assignment constants (read-only):
    %   DAQUSB6009.BIT_PZT    = 1   (line 0)
    %   DAQUSB6009.BIT_ETALON = 2   (line 1)
    %
    % See also: daq, daqlist

    % -------------------------------------------------------------------
    % Public properties
    % -------------------------------------------------------------------
    properties (Access = public)
        DeviceName      % NI-DAQ device identifier, e.g. 'Dev3'
        PortName        % Digital port, default 'port0'
        IsConnected     % true when DAQ is connected and ready
    end

    % -------------------------------------------------------------------
    % Private properties
    % -------------------------------------------------------------------
    properties (Access = private)
        DAQDevice           % daq("ni") session handle
        DigitalChannels     % channels added via addoutput()
        CurrentBitPattern   % uint8, tracks the live output state
    end

    % -------------------------------------------------------------------
    % Bit-position constants
    % -------------------------------------------------------------------
    properties (Constant)
        BIT_PZT    = uint8(1);   % line 0 — PZT interferometer leg paddle
        BIT_ETALON = uint8(2);   % line 1 — Etalon interferometer leg paddle
    end

    % -------------------------------------------------------------------
    % Constructor / destructor
    % -------------------------------------------------------------------
    methods

        function obj = DAQUSB6009(deviceName, portName)
            % DAQUSB6009  Create and connect to the NI DAQ device.
            %
            %   obj = DAQUSB6009('Dev3')
            %   obj = DAQUSB6009('Dev3', 'port0')

            if nargin < 1 || isempty(deviceName)
                error('DAQUSB6009:InvalidInput', 'Device name is required.');
            end
            if nargin < 2 || isempty(portName)
                portName = 'port0';
            end

            if ~(ischar(deviceName) || isstring(deviceName))
                error('DAQUSB6009:InvalidInput', 'Device name must be a string.');
            end
            if ~(ischar(portName) || isstring(portName))
                error('DAQUSB6009:InvalidInput', 'Port name must be a string.');
            end

            obj.DeviceName        = char(deviceName);
            obj.PortName          = char(portName);
            obj.IsConnected       = false;
            obj.CurrentBitPattern = uint8(0);

            try
                obj.connect();
                fprintf('DAQUSB6009: connected on %s/%s\n', obj.DeviceName, obj.PortName);
            catch ME
                error('DAQUSB6009:ConnectionFailed', ...
                    'Failed to connect to DAQ device: %s', ME.message);
            end
        end

        % ---------------------------------------------------------------
        function delete(obj)
            % Destructor — safely zeros outputs and releases the session.
            obj.disconnect();
        end

    end   % constructor / destructor

    % -------------------------------------------------------------------
    % Public API — high-level solenoid control
    % -------------------------------------------------------------------
    methods (Access = public)

        function setSolenoid(obj, legName, state)
            % setSolenoid  Set a single paddle solenoid on or off.
            %
            %   daq.setSolenoid('pzt',    true)   % block PZT leg
            %   daq.setSolenoid('etalon', false)  % unblock Etalon leg
            %
            %   legName : 'pzt' | 'etalon'  (case-insensitive)
            %   state   : true/1 = block beam  |  false/0 = unblock beam

            obj.checkConnected();
            bit = obj.legNameToBit(legName);

            if state
                newPattern = bitor(obj.CurrentBitPattern, bit);
            else
                newPattern = bitand(obj.CurrentBitPattern, bitcmp(bit, 'uint8'));
            end

            obj.writePattern(newPattern);
            fprintf('DAQUSB6009: %s leg -> %s\n', ...
                upper(legName), obj.stateLabel(state));
        end

        % ---------------------------------------------------------------
        function blockPZT(obj)
            % blockPZT  Block the PZT interferometer leg.
            obj.setSolenoid('pzt', true);
        end

        function unblockPZT(obj)
            % unblockPZT  Unblock the PZT interferometer leg.
            obj.setSolenoid('pzt', false);
        end

        function blockEtalon(obj)
            % blockEtalon  Block the Etalon interferometer leg.
            obj.setSolenoid('etalon', true);
        end

        function unblockEtalon(obj)
            % unblockEtalon  Unblock the Etalon interferometer leg.
            obj.setSolenoid('etalon', false);
        end

        function unblockAll(obj)
            % unblockAll  Clear all outputs — both legs unblocked.
            %   Equivalent to legacy: DAQdigOut(panel, 0)
            obj.checkConnected();
            obj.writePattern(uint8(0));
            fprintf('DAQUSB6009: all legs unblocked (output = 0)\n');
        end

        function blockAll(obj)
            % blockAll  Block both legs simultaneously.
            %   Equivalent to legacy: DAQdigOut(panel, 3)
            obj.checkConnected();
            newPattern = bitor(obj.BIT_PZT, obj.BIT_ETALON);
            obj.writePattern(newPattern);
            fprintf('DAQUSB6009: both legs blocked (output = %d)\n', newPattern);
        end

        % ---------------------------------------------------------------
        function s = getState(obj)
            % getState  Return the current solenoid state as a struct.
            %
            %   s = daq.getState();
            %   s.pzt    -> true if PZT leg is blocked
            %   s.etalon -> true if Etalon leg is blocked
            %   s.raw    -> raw uint8 bit pattern

            s.pzt    = logical(bitand(obj.CurrentBitPattern, obj.BIT_PZT));
            s.etalon = logical(bitand(obj.CurrentBitPattern, obj.BIT_ETALON));
            s.raw    = obj.CurrentBitPattern;
        end

        % ---------------------------------------------------------------
        function writeRaw(obj, value)
            % writeRaw  Write an arbitrary 8-bit value directly to the port.
            %   Provided for compatibility with legacy DAQdigOut() calls.
            %
            %   daq.writeRaw(0)   % all off
            %   daq.writeRaw(1)   % PZT blocked
            %   daq.writeRaw(2)   % Etalon blocked
            %   daq.writeRaw(3)   % both blocked

            obj.checkConnected();

            if ~isnumeric(value) || ~isscalar(value) || ...
               value < 0 || value > 255 || mod(value,1) ~= 0
                error('DAQUSB6009:InvalidInput', ...
                    'Raw value must be an integer in [0, 255].');
            end

            obj.writePattern(uint8(value));
        end

    end   % public API

    % -------------------------------------------------------------------
    % Connection management
    % -------------------------------------------------------------------
    methods (Access = public)

        function connect(obj)
            % connect  Open the DAQ session and configure digital output.
            %
            %   NOTE: All 8 lines on the port are added (port0/line0:7).
            %   The USB-6009 DAQ Toolbox driver requires this — adding a
            %   subset of lines causes write() to silently fail.

            if obj.IsConnected
                warning('DAQUSB6009:AlreadyConnected', ...
                    'Device is already connected.');
                return;
            end

            % Build the line spec: e.g. 'port0/line0:7'
            lineSpec = sprintf('%s/line0:7', obj.PortName);

            try
                obj.DAQDevice = daq("ni");
                obj.DigitalChannels = addoutput( ...
                    obj.DAQDevice, obj.DeviceName, lineSpec, 'Digital');

                % Zero outputs on connect (safety)
                obj.writePattern(uint8(0));
                obj.IsConnected = true;

            catch ME
                obj.IsConnected = false;
                error('DAQUSB6009:ConnectionError', ...
                    'DAQ setup failed: %s', ME.message);
            end
        end

        function disconnect(obj)
            % disconnect  Zero outputs and release the DAQ session.

            if ~obj.IsConnected
                return;
            end

            try
                % Zero outputs before releasing (safety)
                obj.writePattern(uint8(0));

                if ~isempty(obj.DAQDevice)
                    clear obj.DAQDevice;
                    obj.DAQDevice = [];
                end
                obj.IsConnected = false;
                fprintf('DAQUSB6009: disconnected\n');

            catch ME
                warning('DAQUSB6009:DisconnectError', ...
                    'Error during disconnect: %s', ME.message);
            end
        end

    end   % connection management

    % -------------------------------------------------------------------
    % Static utilities
    % -------------------------------------------------------------------
    methods (Static)

        function listDevices()
            % listDevices  Print all NI-DAQ devices visible to MATLAB.
            try
                devices = daqlist("ni");
                if isempty(devices)
                    fprintf('No NI-DAQ devices found.\n');
                else
                    fprintf('Available NI-DAQ devices:\n');
                    disp(devices);
                end
            catch ME
                error('DAQUSB6009:ListError', ...
                    'Failed to list devices: %s', ME.message);
            end
        end

    end   % static utilities

    % -------------------------------------------------------------------
    % Private helpers
    % -------------------------------------------------------------------
    methods (Access = private)

        function checkConnected(obj)
            if ~obj.IsConnected
                error('DAQUSB6009:NotConnected', ...
                    'DAQ not connected. Call connect() first.');
            end
        end

        function bit = legNameToBit(~, legName)
            % Map a leg name string to its uint8 bitmask.
            switch lower(char(legName))
                case 'pzt'
                    bit = uint8(1);   % line 0
                case 'etalon'
                    bit = uint8(2);   % line 1
                otherwise
                    error('DAQUSB6009:UnknownLeg', ...
                        'Unknown leg name "%s". Use "pzt" or "etalon".', legName);
            end
        end

        function writePattern(obj, pattern)
            % writePattern  Write an 8-bit pattern to the DAQ port.
            %
            %   Converts a uint8 scalar into an 8-element row vector
            %   [line0 line1 ... line7] as expected by the DAQ Toolbox
            %   write() function when all 8 lines are added.

            lineVector = bitget(pattern, 1:8);   % [line0 .. line7]
            write(obj.DAQDevice, lineVector);
            obj.CurrentBitPattern = uint8(pattern);
        end

        function lbl = stateLabel(~, state)
            if state
                lbl = 'BLOCKED';
            else
                lbl = 'UNBLOCKED';
            end
        end

    end   % private helpers

end