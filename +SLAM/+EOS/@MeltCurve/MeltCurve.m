% Melt curve class
%
% This class supports melt curves based on the Kechin formula:
%    T = T0*[1+(P-P0)/P1]^b * exp[-(P-P0)/P2]
% as described in "Thermodynamically based melting-curve equation", Journal
% Physics: Condensed Matter v 7, 531 (1995).  In the limit P2 => infinity,
% this expression reduces to the more common Simon-Glatzel equation.
%    (T/T0)^c = 1 + (P-P0)/P1
% The exponent in the second expression is the reciprocal of that of the
% first expression (b=1/c).  The reference state is defined by (P0,T0).
% Characteristic pressure scaling is defined by P1 and P2.
%
% Melt curve parameters may be specified at object creation:
%    object=MeltCurve(param);
% later on through the define method.  At some point, material parameters
% will be available by name using the lookup method.
% 
% See also SLAM.EOS
%
classdef MeltCurve < SLAM.Developer.SimpleHandle
    %%
    properties (SetAccess=protected)
        Parameter
        Pressure
        Temperature
    end
    %%
    methods
        function object=MeltCurve(varargin)
            try
                define(object,varargin{:});
            catch ME
                throwAsCaller(ME);
            end
        end
    end
    %%
    methods (Static=true)
        varargout=lookup(varargin)
    end
end