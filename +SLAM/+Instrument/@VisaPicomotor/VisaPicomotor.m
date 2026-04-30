% VISA Picomotor class
%
% This class implements Picomotor control over a VISA serial connection
% (USB-to-DB9 serial).  Objects are created through the static connect
% method.
%
%    pico = VisaPicomotor.connect('ASRL4::INSTR');
%
% See also SLAM.Instrument, Picomotor, TcpipPicomotor
%
classdef VisaPicomotor < SLAM.Instrument.Picomotor
    methods (Hidden=true)
        function object=VisaPicomotor(device)
            object=object@SLAM.Instrument.Picomotor(device,'VISA');
        end
    end
    methods (Static=true)
        varargout=connect(varargin)
    end
end