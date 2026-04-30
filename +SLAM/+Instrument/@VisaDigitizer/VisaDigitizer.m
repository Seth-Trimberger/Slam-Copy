% VISA digitizer class
%
% This class implements digitizer control over a VISA connection.
% Objects are typically created through the static connect method and then
% linked with a command library.
%
% See also SLAM.Instrument
%
classdef VisaDigitizer < SLAM.Instrument.Digitizer
    methods (Hidden=true)
        function object=VisaDigitizer(device)
            object=object@SLAM.Instrument.Digitizer(device);
        end
    end
    methods (Static=true)
        varargout=connect(varargin);
    end
end