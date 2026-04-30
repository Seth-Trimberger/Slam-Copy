% NI USB-6009 digital output controller for VISAR beam paddles
%
% This class controls the NI USB-6009 (or USB-6501) DAQ device for
% driving optical beam-blocking solenoids (paddles) in the VISAR
% interferometer.  Objects are created through the static connect method.
%
%    daq = DAQUSB6009.connect('Dev3');
%
% USAGE EXAMPLES:
%
%    % List available NI-DAQ devices
%    DAQUSB6009.listDevices();
%
%    % Connect to device
%    daq = DAQUSB6009.connect('Dev3');
%
%    % Individual paddle control
%    blockPZT(daq);             % block PZT interferometer leg
%    unblockPZT(daq);           % unblock PZT leg
%    blockEtalon(daq);          % block Etalon interferometer leg
%    unblockEtalon(daq);        % unblock Etalon leg
%
%    % Convenience methods
%    blockAll(daq);             % block both legs
%    unblockAll(daq);           % unblock both legs
%
%    % Named paddle control
%    setSolenoid(daq, 'pzt', true);       % block PZT leg
%    setSolenoid(daq, 'etalon', false);   % unblock Etalon leg
%
%    % Query current state
%    s = getState(daq);         % returns struct: s.pzt, s.etalon, s.raw
%
%    % Raw legacy-compatible write (matches C DAQdigOut values)
%    writeRaw(daq, 0);          % all off
%    writeRaw(daq, 1);          % PZT blocked
%    writeRaw(daq, 2);          % Etalon blocked
%    writeRaw(daq, 3);          % both blocked
%
%    % Disconnect
%    delete(daq);
%
% PADDLE / BIT MAPPING:
%
%    Line 0 (value 1) = PZT leg paddle
%    Line 1 (value 2) = Etalon leg paddle
%
%    This maps to the legacy C DAQdigOut() calls:
%      DAQdigOut(panel, 0)  ->  both unblocked
%      DAQdigOut(panel, 1)  ->  PZT blocked
%      DAQdigOut(panel, 2)  ->  Etalon blocked
%      DAQdigOut(panel, 3)  ->  both blocked
%
% HARDWARE NOTES:
%
%    - All 8 lines on the port must be added (port0/line0:7).
%      Adding only a subset causes write() to silently fail.
%    - write() expects an 8-element numeric row vector.
%    - NI MAX test panels hold an exclusive device lock; close
%      MAX before using this class.
%    - Requires: Data Acquisition Toolbox + NI-DAQmx driver
%
% See also SLAM.Instrument
%
classdef DAQUSB6009 < SLAM.Developer.SimpleHandle
    %% device name
    properties
        Name % Device display name
    end
    methods
        function set.Name(object,value)
            if isStringScalar(value)
                value=char(value);
            end
            if ~ischar(value)
                error('DAQUSB6009:Name','device name must be a character array or string');
            end
            object.Name=value;
        end
    end
    %% device
    properties (SetAccess=protected)
        DeviceName        % NI-DAQ device identifier, e.g. 'Dev3'
        PortName          % Digital port, default 'port0'
        IsConnected       % true when DAQ is connected and ready
        DAQDevice         % daq("ni") session handle
        CurrentBitPattern % uint8, tracks the live output state
    end
    %% bit-position constants
    properties (Constant)
        BIT_PZT    = uint8(1)   % line 0 - PZT interferometer leg paddle
        BIT_ETALON = uint8(2)   % line 1 - Etalon interferometer leg paddle
    end
    %%
    methods (Hidden=true)
        function object=DAQUSB6009(device,deviceName,portName)
            object.DAQDevice=device;
            object.DeviceName=deviceName;
            object.PortName=portName;
            object.IsConnected=true;
            object.CurrentBitPattern=uint8(0);
            object.Name=sprintf('USB-6009 (%s)',deviceName);
        end
    end
    %%
    methods (Static=true)
        varargout=connect(varargin)
        varargout=listDevices(varargin)
        varargout=manage(varargin)
    end
    methods
        varargout=setSolenoid(varargin)
        varargout=blockPZT(varargin)
        varargout=unblockPZT(varargin)
        varargout=blockEtalon(varargin)
        varargout=unblockEtalon(varargin)
        varargout=blockAll(varargin)
        varargout=unblockAll(varargin)
        varargout=getState(varargin)
        varargout=writeRaw(varargin)
    end
    methods (Hidden=true)
        varargout=writePattern(varargin)
    end
end