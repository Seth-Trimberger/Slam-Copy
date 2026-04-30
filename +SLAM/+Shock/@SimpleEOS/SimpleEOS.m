% UNDER CONSTRUCTION
%
%
% SI units!
%
%
% See also SLAM.Shock
%

% [wrong]
% Pressure in GPa
% Density in g/cc, specific volume in cc/g
% Velocities in km/s
% Specific heat in J/g*K?
%
classdef SimpleEOS < handle

    %%
    properties (SetAccess=protected)
        Parameters              % EOS parameters [rho0 c0 s cv gamma0]
        Reference               % P(v) reference curve 
        Pressure = 0            % Current pressure (GPa)
        Density                 % Current density (g/cc)
        ParticleVelocity = 0    % Current particle velocity (km/s)
        ShockVelocity           % Current shock velocity (km/s)
        Temperature = 298       % Current temperature (K)
    end
    %%
    methods
        function object=SimpleEOS(parameter)
            % manage input
            Narg=nargin();
            if (Narg < 1) || isempty(parameter)
                %parameter=[8.903e3 3.788e3 1.711 389 2.18];
                parameter=[8.92e3 3.91e3 1.51 390 2.2];
                fprintf('Using the default EOS (copper)\n');
            end
            assert(isnumeric(parameter) && all(isfinite(parameter)) ...
                && all(parameter > 0),'ERROR: invalid EOS parameter(s)');
            parameter=reshape(parameter,1,[]);
            NP=numel(parameter);
            if NP == 5
                parameter=[298 parameter];
            elseif NP > 6
                error('ERROR: too many EOS parameters');
            end
            % set up object
            object.Parameters=parameter;
            initialize(object,[],'noplots');
            object.Density=object.Parameters(2);
            setParticleVelocity(object,0);
            object.ShockVelocity=object.Parameters(3);
        end
    end
    %%
    methods (Static=true)
        varargout=lookup(varargin)
    end
end