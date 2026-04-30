% TCP/IP digitizer class
%
% This class implements digitizer control over a TCP/IP connection.
% Objects are typically created through the static connect method and then
% linked with a command library.
%
% See also SLAM.Instrument
%
classdef TcpipDigitizer < SLAM.Instrument.Digitizer
    methods (Hidden=true)
        function object=TcpipDigitizer(device)
            object=object@SLAM.Instrument.Digitizer(device);
        end
    end
    methods (Static=true)
        varargout=connect(varargin);
    end
end