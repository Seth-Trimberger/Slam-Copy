% UNDER CONSTRUCTION
%
% 
%
% See also SLAM.Instrument
%
classdef Tektronix2456 < SLAM.Developer.SimpleHandle
    %%
    properties (SetAccess=protected)
        Device           % Device VISA connection
        ModelNumber      % ModelNumber Digitizer model
        SerialNumber     % SerialNumber Digitizer serial number
        CodeNumber       % CodeNumber Code/formats number
        FirmwareVersion  % FirmwareVersion Digitizer firmware version
        Channels         % Channels Number of digitizer channels
    end
    %
    properties
        Delay = 0.01     % Delay Time increment for query checking
    end
    methods
        function set.Delay(object,value)
            assert(isnumeric(value) && isscalar(value) && (value > 0),...
                'ERROR: query delay must be a number > 0');
            object.Delay=value;
        end
    end
    %%
    methods (Hidden=true)
        function object=Tektronix2456(device)
            object.Device=device;
            try
                response=writeread(object.Device,'*IDN?');
            catch ME
                error('ERROR: invalid VISA device');
            end
            response=char(response);
            response=extractAfter(response,',');
            object.ModelNumber=extractBefore(response,',');
            switch upper(object.ModelNumber)
                case {'MSO44B' 'MSO46B'}
                case {'MSO54B' 'MSO56B' 'MSO58B' 'MSO58LP'}
                case {'MSO64B' 'MSO66B' 'MSO68B' 'LPD64'}
                otherwise
                    error('ERROR: unsupported digitizer model');
            end
            response=extractAfter(response,',');           
            object.SerialNumber=extractBefore(response,',');
            response=extractAfter(response,':');
            object.CodeNumber=strtrim(extractBefore(response,'FV:'));
            object.FirmwareVersion=strtrim(extractAfter(response,'FV:'));
            writeline(object.Device,':HEADER OFF; VERBOSE ON');
            object.Channels=sscanf(object.ModelNumber(5),'%g',1);
        end
    end
    methods (Static=true)
        %varargout=list(varargin)
        varargout=connect(varargin)
    end
end