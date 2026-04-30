% UNDER CONSTRUCTION
% Zaber motorized stage class
%
% 
%
% Limitations: currently designed for one system with one axis
classdef Zaber < SLAM.Developer.SimpleHandle
    properties (SetAccess = protected)
        Connection    % Instrument connection
        SerialNumber  % Device serial number
        ID            % Device ID number
    end
    properties (SetAccess=protected, Hidden=true)
        LastPositionRequest = ''
    end
    %% automatic buffer flushing
    properties 
        AutoFlush = 'on' % Automatic buffer flush
    end
    methods
        function set.AutoFlush(object,value)
            if any(strcmpi(value,{'on' 'off'}))
                object.AutoFlush=lower(char(value));
            else
                error('ERROR: auto flush must be ''on'' or ''off''');
            end
        end
    end
    %% constructor
    methods 
        function object=Zaber(port)
            assert(nargin > 0,'ERROR: serial port must be specified');
            BaudRate=115200;
            try
                object.Connection=serialport(port,BaudRate,'Timeout',1);
                [~,report]=communicate(object,'/get device.id');                
            catch ME
                throwAsCaller(ME);
            end
            object.ID=report.Data;
            [~,report]=communicate(object,'/get system.serial');
            object.SerialNumber=report.Data;
        end
    end
    %%
    methods (Static=true)
        varargout=scan(varargin)
    end
end