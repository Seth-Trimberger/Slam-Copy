% Jump condition object class
%
% This class supports jump condition calculations, which link states ahead
% and behind a steady shock wave.  Once an object is created:
%    object=JumpConditions();
% its properties can be adjusted to define mass density and pressure ahead
% of the shock front.
%    object.InitialDensity=rho0; 
%    object.InitialPressure=P0;
% These properties are used in the calculate methods to link shock variable
% pairs.
%
% NOTE: this class does not enforce any particular set of units, so any
% consistent choice can be used.  The recommended convention is:
%    -Density in g/cc and specific volume in cc/g.
%    -Pressure in GPa.
%    -Particle and shock velocity in km/s.
% 
classdef JumpConditions
    %%
    properties
        InitialDensity  = 1 % Density ahead of the shock front
        InitialPressure = 0 % Pressure ahead of the shock front
    end
    methods
        function object=set.InitialDensity(object,value)
            assert(isnumeric(value) && isscalar(value)...
                && isfinite(value) && (value > 0),...
                'ERROR: invalid initial density');
            object.InitialDensity=value;
        end
        function object=set.InitialPressure(object,value)
            assert(isnumeric(value) && isscalar(value)...
                && isfinite(value),'ERROR: invalid initial pressure');
            object.InitialPressure=value;
        end
    end
    %%    
    methods (Hidden=true)
        function object=JumpConditions(varargin)
        end
    end
    %%
    methods (Static=true)
        varargout=showEquations(varargin)
        varargout=showExample(varargin)
    end
end