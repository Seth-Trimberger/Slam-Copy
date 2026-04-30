% TCP/IP Picomotor class
%
% This class implements Picomotor control over a TCP/IP connection
% (the legacy connection mode, port 23).  Objects are created through
% the static connect method.
%
%    pico = TcpipPicomotor.connect('10.2.2.209');
%    pico = TcpipPicomotor.connect('10.2.2.209',23);
%
% See also SLAM.Instrument, Picomotor, VisaPicomotor
%
classdef TcpipPicomotor < SLAM.Instrument.Picomotor
    methods (Hidden=true)
        function object=TcpipPicomotor(device)
            object=object@SLAM.Instrument.Picomotor(device,'TCP');
        end
    end
    methods (Static=true)
        varargout=connect(varargin)
    end
end