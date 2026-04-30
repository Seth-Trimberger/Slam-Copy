% Coherent Verdi V-10 laser class
%
% This class implements control of the Coherent Verdi V-10 laser over a
% VISA serial connection.  Objects are created through the static connect
% method.
%
%    laser = Verdi.connect('ASRL4::INSTR');
%
% Documentation:
%    https://github.com/quantumm/user_manual/blob/main/Coherent_VerdiV10_UserManual.pdf
%
% See also SLAM.Instrument
%
classdef Verdi < SLAM.Developer.SimpleHandle
    %% laser name
    properties
        Name % Laser name
    end
    methods
        function set.Name(object,value)
            if isStringScalar(value)
                value=char(value);
            end
            if ~ischar(value)
                error('Verdi:Name','laser name must be a character array or string');
            end
            object.Name=value;
        end
    end
    %% device
    properties (SetAccess=protected)
        Device   % VISA device connection
    end
    %%
    methods (Hidden=true)
        function object=Verdi(device)
            object.Device=device;
            object.Name='Verdi V-10';
        end
    end
    %%
    methods (Static=true)
        varargout=connect(varargin)
        varargout=manage(varargin)
    end
    methods
        varargout=communicate(varargin)
        varargout=controlShutter(varargin)
        varargout=setOutputPower(varargin)
        varargout=flashEtalon(varargin)
        varargout=controlEcho(varargin)
        varargout=getPowerSetpoint(varargin)
        varargout=getActualLightOutput(varargin)
        varargout=getShutterStatus(varargin)
    end
end