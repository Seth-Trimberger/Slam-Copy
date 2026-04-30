% Generic digitizer class
%
% This abstract class defines core aspects of digitizer control.  It cannot
% be used directly, but must instead be subclassed into a particular
% connection type (e.g., TCP/IP or VISA).  These derived classes are meant
% be used in conjunction with a command library, which defines features and
% actions specific to a particular vendor/model.
%
% See also SLAM.Instrument, TcpipDigitizer, VisaDigitizer
%
classdef Digitizer < SLAM.Developer.SimpleHandle & matlab.mixin.Heterogeneous
    %% digitizer name
    properties
        Name % Digitizer name
    end
    methods
        function set.Name(object,value)
            if isStringScalar(value)
                value=char(value);
            end
            assert(ischar(value),'ERROR: invalid digitizer name');
            object.Name=value;
        end
    end
    %% device
    properties (SetAccess=protected)
        Device       % Device connection
        IDN          % Device identification string
        Options      % Device options
        Vendor       % Device vendor
        Model        % Device model number
        Serial       % Device serial number
        Library      % Command library
        Feature      % Device features
        Action       % Device actions
        Timer        % Arm status timer
    end
    %%
    properties 
        Verbose = 'on' % Verbose mode (arm/trigger monitor)
    end
    methods
        function set.Verbose(object,value)
            valid={'on' 'off'};
            assert(any(strcmpi(value,value)),...
                'ERROR: verbose must be ''%s'' or ''%s''',valid{:})
            object.Verbose=lower(value);
        end
    end
    properties (Dependent=true)
        Refresh  % Refresh time (arm/trigger monitor)
    end
    methods
        function value=get.Refresh(object)
            value=object.Timer.Period;
        end
        function set.Refresh(object,value)
            if strcmpi(object.Timer.Running,'on')
                stop(object.Timer);
                CU=onCleanup(@() start(object.Timer));
            end
            try
                object.Timer.Period=value;
            catch ME
                throwAsCaller(ME);
            end
        end
    end
    %%
    methods (Hidden=true)
        function object=Digitizer(device)
            object.Device=device;
            object.IDN=communicate(object,'*IDN?');
            object.Options=communicate(object,'*OPT?');
            buffer=object.IDN;
            object.Vendor=extractBefore(buffer,',');
            buffer=extractAfter(buffer,',');
            object.Model=extractBefore(buffer,',');
            buffer=extractAfter(buffer,',');
            object.Serial=extractBefore(buffer,',');
            %
            persistent counter
            if isempty(counter)
                counter=1;
            end
            object.Name=sprintf('Digitizer %d',counter);
            counter=counter+1;
            %
            object.Timer=timer('ExecutionMode','fixedSpacing');
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
    methods (Sealed=true)
        varargout=invoke(varargin)
    end
end