classdef VISARConfig
% VISARConfig  Reads VISARconfig.txt and exposes all system-wide settings
%   as properties. This is the single source of truth for hardware
%   addresses and system configuration. Pass a VISARConfig object to other
%   hardware classes instead of hardcoded values.
%
%   USAGE:
%       cfg = VISARConfig();                      % reads 'VISARconfig.txt' in CWD
%       cfg = VISARConfig('VISARconfigMP.txt');   % explicit file path
%
%   CONFIG FILE FORMAT (10 lines):
%       Line 1  - IsRemote          (0=local, 1=remote)
%       Line 2  - IsMultiPoint      (0=single-point, 1=multi-point)
%       Line 3  - RemoteName        (ethernet name for remote server, e.g. visar2)
%       Line 4  - ScopeAddresses{1} (VISA address for scope 1)
%       Line 5  - ScopeAddresses{2} (VISA address for scope 2, or NOADDR)
%       Line 6  - ScopeAddresses{3} (VISA address for scope 3, or NOADDR)
%       Line 7  - ScopeAddresses{4} (VISA address for scope 4, or NOADDR)
%       Line 8  - PicomotorAddress  (IP/hostname of picomotor controller)
%       Line 9  - DetectorPolarity  (4 comma-separated values: +1 or -1)
%       Line 10 - LaserSerialConnected (0 or 1)
%
%   NOADDR entries are stored as empty string '' in ScopeAddresses.
%
%   Legacy source: VISARconfig.txt + Initialize() in VISARctrl.c

    properties (SetAccess = private)
        % Line 1 - Remote operation flag
        % 0 = local (direct VISA), 1 = remote (VISARremote server required)
        IsRemote (1,1) logical = false

        % Line 2 - VISAR configuration type
        % false = single-point, true = multi-point
        IsMultiPoint (1,1) logical = false

        % Line 3 - Ethernet hostname for remote server (e.g. 'visar2')
        % Used only when IsRemote == true
        RemoteName (1,:) char = 'visar1'

        % Lines 4-7 - VISA addresses for up to 4 oscilloscopes
        % NOADDR entries are stored as '' (empty string)
        % Example: 'TCPIP0::10.150.1.238::inst0::INSTR'
        ScopeAddresses (1,4) cell = {'', '', '', ''}

        % Line 8 - IP address or hostname for Picomotor 8742 controller
        % Port is fixed at 23 (set by hardware)
        PicomotorAddress (1,:) char = '10.2.2.209'

        % Line 9 - Detector polarity for each of the 4 scopes (+1 or -1)
        DetectorPolarity (1,4) double = [-1, -1, -1, -1]

        % Line 10 - Whether a serial cable connects scope 1 to the laser
        % Required for 10W Verdi; optional for 5W Verdi
        LaserSerialConnected (1,1) logical = false

        % Path of the config file that was actually loaded
        ConfigFilePath (1,:) char = ''
    end

    properties (Dependent)
        % Number of active (non-NOADDR) scope addresses
        ActiveScopeCount

        % Cell array of only the active scope addresses (no empty entries)
        ActiveScopeAddresses
    end

    % -----------------------------------------------------------------------
    %  Default values match the fallback defaults in VISARctrl.c Initialize()
    % -----------------------------------------------------------------------
    properties (Constant, Access = private)
        DEFAULT_REMOTE_NAME       = 'visar1'
        DEFAULT_SCOPE_ADDRESS_1   = 'TCPIP::visar1::INSTR'
        DEFAULT_PICO_ADDRESS      = '10.2.2.209'
        DEFAULT_POLARITY          = [-1, -1, -1, -1]
        NOADDR_TOKEN              = 'NOADDR'
    end

    methods
        % -------------------------------------------------------------------
        function obj = VISARConfig(configFilePath)
        % VISARConfig  Constructor. Reads and parses the config file.
        %
        %   obj = VISARConfig()
        %       Looks for 'VISARconfig.txt' in the current directory.
        %
        %   obj = VISARConfig(configFilePath)
        %       Loads the specified file path.

            if nargin < 1 || isempty(configFilePath)
                configFilePath = 'VISARconfig.txt';
            end

            obj = obj.LoadConfigFile(configFilePath);
        end

        % -------------------------------------------------------------------
        function count = get.ActiveScopeCount(obj)
        % Returns the number of scope addresses that are not NOADDR/empty.
            count = sum(~cellfun(@isempty, obj.ScopeAddresses));
        end

        % -------------------------------------------------------------------
        function addrs = get.ActiveScopeAddresses(obj)
        % Returns a cell array of only the non-empty scope addresses.
            mask  = ~cellfun(@isempty, obj.ScopeAddresses);
            addrs = obj.ScopeAddresses(mask);
        end

        % -------------------------------------------------------------------
        function Display(obj)
        % Display  Prints a formatted summary of the loaded configuration.
            fprintf('\n--- VISARConfig ---\n');
            fprintf('  File           : %s\n', obj.ConfigFilePath);
            fprintf('  IsRemote       : %d\n', obj.IsRemote);
            fprintf('  IsMultiPoint   : %d\n', obj.IsMultiPoint);
            fprintf('  RemoteName     : %s\n', obj.RemoteName);
            for i = 1:4
                addr = obj.ScopeAddresses{i};
                if isempty(addr)
                    addr = '(NOADDR)';
                end
                fprintf('  Scope %d        : %s\n', i, addr);
            end
            fprintf('  PicomotorAddr  : %s\n', obj.PicomotorAddress);
            fprintf('  DetPolarity    : [%d, %d, %d, %d]\n', ...
                obj.DetectorPolarity(1), obj.DetectorPolarity(2), ...
                obj.DetectorPolarity(3), obj.DetectorPolarity(4));
            fprintf('  LaserSerial    : %d\n', obj.LaserSerialConnected);
            fprintf('  Active scopes  : %d\n', obj.ActiveScopeCount);
            fprintf('-------------------\n\n');
        end
    end

    methods (Access = private)
        % -------------------------------------------------------------------
        function obj = LoadConfigFile(obj, filePath)
        % LoadConfigFile  Opens and parses the 10-line VISARconfig.txt file.
        %   Falls back to hardcoded defaults (matching VISARctrl.c) if the
        %   file cannot be opened.

            fid = fopen(filePath, 'r');

            if fid == -1
                fprintf('VISARConfig: WARNING - cannot open "%s". Using defaults.\n', filePath);
                obj = obj.ApplyDefaults();
                obj.ConfigFilePath = filePath;  % record attempted path
                return;
            end

            fprintf('VISARConfig: Reading "%s"\n', filePath);

            try
                % Line 1 - IsRemote
                line1 = strtrim(fgetl(fid));
                obj.IsRemote = logical(str2double(line1));

                % Line 2 - IsMultiPoint
                line2 = strtrim(fgetl(fid));
                obj.IsMultiPoint = logical(str2double(line2));

                % Line 3 - RemoteName (ethernet name for remote server)
                line3 = strtrim(fgetl(fid));
                obj.RemoteName = line3;

                % Lines 4-7 - Scope VISA addresses
                addrs = cell(1,4);
                for i = 1:4
                    raw = strtrim(fgetl(fid));
                    if strcmpi(raw, obj.NOADDR_TOKEN)
                        addrs{i} = '';   % NOADDR -> empty string
                    else
                        addrs{i} = raw;
                    end
                end
                obj.ScopeAddresses = addrs;

                % Line 8 - Picomotor address
                line8 = strtrim(fgetl(fid));
                obj.PicomotorAddress = line8;

                % Line 9 - Detector polarity  (format: "p1,p2,p3,p4")
                line9 = strtrim(fgetl(fid));
                polVals = sscanf(line9, '%d,%d,%d,%d');
                if numel(polVals) == 4
                    obj.DetectorPolarity = polVals(:)';
                else
                    fprintf('VISARConfig: WARNING - could not parse polarity line "%s". Using defaults.\n', line9);
                    obj.DetectorPolarity = obj.DEFAULT_POLARITY;
                end

                % Line 10 - LaserSerialConnected
                line10 = strtrim(fgetl(fid));
                obj.LaserSerialConnected = logical(str2double(line10));

            catch ME
                fprintf('VISARConfig: ERROR parsing "%s": %s\n', filePath, ME.message);
                fprintf('VISARConfig: Applying defaults for remaining fields.\n');
                % Partial state is acceptable; fields already set remain set.
            end

            fclose(fid);
            obj.ConfigFilePath = filePath;
        end

        % -------------------------------------------------------------------
        function obj = ApplyDefaults(obj)
        % ApplyDefaults  Matches the fallback defaults in VISARctrl.c Initialize().
            obj.IsRemote              = true;
            obj.IsMultiPoint          = false;
            obj.RemoteName            = obj.DEFAULT_REMOTE_NAME;
            obj.ScopeAddresses        = {obj.DEFAULT_SCOPE_ADDRESS_1, '', '', ''};
            obj.PicomotorAddress      = obj.DEFAULT_PICO_ADDRESS;
            obj.DetectorPolarity      = obj.DEFAULT_POLARITY;
            obj.LaserSerialConnected  = false;
        end
    end

    methods (Static)
        % -------------------------------------------------------------------
        function obj = FromFile(filePath)
        % FromFile  Named constructor - alternative to calling VISARConfig(path).
        %
        %   cfg = VISARConfig.FromFile('VISARconfigMP.txt');
            obj = VISARConfig(filePath);
        end
    end
end