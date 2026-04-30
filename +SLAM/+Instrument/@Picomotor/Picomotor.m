% New Focus Picomotor 8742 controller base class
%
% This abstract class defines core aspects of Picomotor control.  It
% cannot be used directly, but must instead be subclassed into a
% particular connection type: VisaPicomotor (USB/serial) or
% TcpipPicomotor (Ethernet).
%
% Objects are created through the static connect methods:
%    pico = VisaPicomotor.connect('ASRL4::INSTR');
%    pico = TcpipPicomotor.connect('10.2.2.209');
%
% Or use the manage GUI:
%    Picomotor.manage();
%
% USAGE EXAMPLES:
%
%    % Full move sequence (select axis, set distance, execute)
%    moveRelative(pico, 1, 0, 100);     % Driver 1, Axis 0, +100 steps
%    moveRelative(pico, 2, 1, -50);     % Driver 2, Axis 1, -50 steps
%
%    % Individual commands
%    turnOnDriver(pico, 1);
%    selectAxis(pico, 1, 0);
%    setVelocity(pico, 1, 0, 200);
%    setRelativeMove(pico, 1, 100);
%    executeMove(pico, 1);
%    stopMove(pico);                    % stop all drivers
%
%    % Status
%    defineZero(pico);                  % reset all position counters
%    displayStatus(pico);               % print state summary
%
% MOTOR STATE:
%
%    The controller manages two drivers (1, 2), each with two axes (0, 1),
%    for a total of four motor channels:
%      D1A0, D1A1, D2A0, D2A1
%
%    Matches the legacy C globals: driverOn[], activeAxis[], picoPos[]
%
% COMMANDS (from New Focus 8742 reference / AlignCtrl.c):
%
%    MON d       - motor driver d on
%    MOF d       - motor driver d off
%    CHL d=a     - select axis a on driver d
%    VEL d a=v   - set velocity for driver d, axis a
%    REL d=n     - set relative move distance
%    GO d        - execute move on driver d
%    ST [d]      - stop move (all or specific driver)
%
% DEFAULT SETUP (matches PicoDefaultSetup in TCPio.c):
%    Both drivers ON, both set to Axis 0, all axes velocity 100 steps/sec
%
% See also SLAM.Instrument, VisaPicomotor, TcpipPicomotor
%
classdef Picomotor < SLAM.Developer.SimpleHandle
    %% name
    properties
        Name % Controller display name
    end
    methods
        function set.Name(object,value)
            if isStringScalar(value)
                value=char(value);
            end
            if ~ischar(value)
                error('Picomotor:Name','name must be a character array or string');
            end
            object.Name=value;
        end
    end
    %% device
    properties (SetAccess=protected)
        Device          % Communication object (tcpclient or visadev)
        ConnectionType  % 'TCP' or 'VISA'
    end
    %% motor state (mirrors C globals)
    properties
        DriverOn        % [1x2] logical - is each driver powered on
        ActiveAxis      % [1x2] int - currently selected axis per driver
        Position        % [1x4] int - cumulative step position [D1A0 D1A1 D2A0 D2A1]
        DefaultVelocity % steps/sec, default 100 (matches legacy C value)
    end
    %%
    methods (Hidden=true)
        function object=Picomotor(device,connectionType)
            object.Device=device;
            object.ConnectionType=connectionType;
            object.DriverOn=[false false];
            object.ActiveAxis=[0 0];
            object.Position=[0 0 0 0];
            object.DefaultVelocity=100;
            object.Name='Picomotor 8742';
        end
    end
    %%
    methods (Abstract=true,Static=true)
        varargout=connect(varargin)
    end
    methods (Abstract=true)
        varargout=communicate(varargin)
    end
    %%
    methods (Static=true)
        varargout=manage(varargin)
    end
    methods
        varargout=defaultSetup(varargin)
        varargout=turnOnDriver(varargin)
        varargout=turnOffDriver(varargin)
        varargout=selectAxis(varargin)
        varargout=setVelocity(varargin)
        varargout=setRelativeMove(varargin)
        varargout=executeMove(varargin)
        varargout=moveRelative(varargin)
        varargout=defineZero(varargin)
        varargout=stopMove(varargin)
        varargout=displayStatus(varargin)
    end
end