% Equation of state class
%
% This class supports tabular equation of state (EOS) calculations.
% Objects are defined with raw tabular data and a reference state.
%    object=EOS(data,reference);
% Mandatory input "data" must be a numeric array beginning with two
% integers: number of density points (NR) and number of temperature points
% (NT).  The next NR points define the density grid, followed by NT points
% that define the temperature grid.  Three sets of NR*NT values complete
% the tabulation: pressure, energy, and Helmholtz free energy.
%
% Mandatory input "reference" can either be a scalar (rho0) or two-elmement
% array ([rho0 T0]).  In the former case, T0 is assumed to be 298.15 K.
%
% Direct consturctor calls (as shown above) are not typically needed.  More
% commonly, the static method importFile is used to read information from a
% Sesame data file.
%
% See also SLAM.SESAME, File
%
classdef EOS < SLAM.Developer.SimpleHandle
    %% core properties
    properties
        % Name EOS name
        %
        % This property stores a user-defined name for an EOS object.  Any
        % character array or scalar string can be specified directly.
        %
        % See also EOS
        Name = 'Unnamed EOS'
    end
    methods
        function set.Name(object,value)
            assert(ischar(value) || isStringScalar(value),'ERROR: invalid name');
            object.Name=char(value);
        end
    end
    properties (SetAccess=protected, Hidden=true)
        PressureLookup
        EnergyLookup
        HelmholtzLookup
    end
    properties (SetAccess=protected)
        % ReferencePoint Reference state [rho0 T0]
        %
        % This property stores the reference state [rho0 T0] defined at
        % object creation.
        %
        % See also EOS
        ReferencePoint
    end
    %% evaluation grids and stored values
    properties (SetAccess=protected)
        % Density Density evaluation points
        %
        % This property stores the density grid used for evaluating
        % pressure and other thermodynamic values.
        %
        % See also EOS, setGrid
        Density
        % Temperature Temperature evaluation points
        %
        % This property stores the temperature grid used for evaluating
        % pressure and other thermodynamic values.
        %
        % See also EOS, setGrid
        Temperature
        % Pressure Current pressure evaluation
        %
        % This property stores pressure evaluated on the current
        % density-temperature grid.
        %
        % See also EOS, setGrid
        Pressure
        % Energy Current energy evaluation
        %
        % This property stores specific energy evaluated on the current
        % density-temperature grid.
        %
        % See also EOS, setGrid
        Energy
        % Helmholtz Current Helmholtz free energy evaluation
        %
        % This property stores specific Helmholtz free energy evaluated on
        % the current density-temperature grid.
        %
        % See also EOS, setGrid
        Helmholtz
        % Entropy Current entropy evaluation
        %
        % This property stores specific entropy evaluated on the current
        % density-temperature grid.
        %
        % See also EOS, setGrid
        Entropy
    end    
    %% constructor
    methods (Hidden=true)
        function object=EOS(data,reference,varargin)
            % manage input
            Narg=nargin();
            assert(Narg >= 2,'ERROR: EOS data and reference state must be specified');
            % process data array
            try
                assert(isnumeric(data));
                NR=data(1);
                assert((NR > 1) && (NR == round(NR)));
                NT=data(2);
                assert((NT > 1) && (NT == round(NT)));
                data=data(3:end);
                density=transpose(data(1:NR));
                data=data(NR+1:end);
                temperature=data(1:NT);
                data=data(NT+1:end);
                N=NR*NT;
                pressure=reshape(data(1:N),NR,NT);
                data=data(N+1:end);
                energy=reshape(data(1:N),NR,NT);
                data=data(N+1:end);
                if isempty(data)
                    helmholtz=nan(NR,NT);
                    warning('301 table is missing Helmholtz free energy');
                else
                    helmholtz=reshape(data(1:N),NR,NT);
                end
                data=data(N+1:end);
                assert(isempty(data));
            catch
                error('ERROR: invalid EOS data');
            end
            arg={density temperature};
            % NEED TO IMPLMENT RATIONAL INTERPOLATION DESCRIBED BY KERLEY
            % IN LA-6903-MS (1977).  Makima seems to be the least bad
            % choice for now, especially when one is not calculating
            % derivatives.
            object.PressureLookup=griddedInterpolant(arg,pressure,'makima');
            object.EnergyLookup=griddedInterpolant(arg,energy,'makima');
            object.HelmholtzLookup=griddedInterpolant(arg,helmholtz,'makima');
            % process reference state
            assert(isnumeric(reference) && any(size(reference) == [1 2]),...
                'ERROR: invalid reference state');
            rho0=reference(1);
            assert(rho0 > 0,'ERROR: invalid reference density');
            if isscalar(reference)
                T0=298.15;
            else
                T0=reference(2);
                assert(T0 >= 0);
            end
            object.ReferencePoint=[rho0 T0];
            % standard evaluation
            setGrid(object);
        end
    end
    %%
    methods (Static=true)
        varargout=importFile(varargin)
    end
end