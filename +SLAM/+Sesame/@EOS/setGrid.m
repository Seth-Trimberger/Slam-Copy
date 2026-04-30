% setGrid Define density-temperature points
%
% This method defines density and temperature values used to evaluate all
% other quantities (pressure, energy, etc.).
%    setGrid(object,density,temperature);
% Optional inputs "density" and "temperature" must be numerical arrays.
% Default values are used if either are omitted/empty.
%    -The default density grid is 999 points spanning from 0.90 to 2.0
%    times the ambient value.
%    -The default temperature grid is 1001 points spanning from 200 to
%    10,000 K.
% Any number of grid points can be specified with the understanding that
% dense grids provide finer interpolation but slower performance and larger
% memory overhead.
%
% See also EOS
%
function setGrid(object,density,temperature)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(density)
    rho0=object.ReferencePoint(1);
    density=linspace(0.90*rho0,2*rho0,999);
else
    assert(isnumeric(density) && all(density >= 0),...
        'ERROR: invalid density grid');
end

if (Narg < 3) || isempty(temperature)
    temperature=linspace(200,10e3,1001);
else
    assert(isnumeric(temperature) && all(temperature >= 0),...
        'ERROR: invalid temperature grid');
end

% create and store grids
density=unique(density(:));
temperature=unique(temperature(:));
[density,temperature]=ndgrid(density,temperature);
object.Density=density;
object.Temperature=temperature;

% evaluate 
object.Pressure=object.PressureLookup(density,temperature);
object.Energy=object.EnergyLookup(density,temperature);
object.Helmholtz=object.HelmholtzLookup(density,temperature);
object.Entropy=(object.Energy-object.Helmholtz)./object.Temperature;
object.Energy(object.Temperature == 0)=0;

end