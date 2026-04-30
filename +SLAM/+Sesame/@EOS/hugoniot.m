% hugoniot Calculate Hugoniot
%
% This method calclates the Hugoniot curve, i.e. states accessible by shock
% compression.  Results can be automatically plotted in a new figure:
%    hugoniot(object,reference);
% or returned as a set of one-dimensional arrays.
%    [rho,T,P]=hugoniot(object,reference);
% Optional input "reference" defines the initial state for shock
% compression, specified as [rho0 T0].  The reference point is used by
% default when this input is empty/omitted.
%
% See also EOS
%
function varargout=hugoniot(object,reference)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(reference)
    reference=object.ReferencePoint;
else
    assert(isnumeric(reference) && (numel(reference) == 2) ...
        && all(reference >= 0),'ERROR: invalid reference state');
end

% reference state
rho0=reference(1);
v0=1/rho0;
T0=reference(2);
P0=object.PressureLookup(rho0,T0);
e0=object.EnergyLookup(rho0,T0);

% calculations
v=1./object.Density;
z=object.Energy-(object.Pressure+P0).*(v0-v);
data=extractContours(object.Density(:,1),object.Temperature(1,:),z, ...
    repmat(e0,[1 2]));
density=data{1}(:,1);
temperature=data{1}(:,2);
keep=(density >= rho0);
density=density(keep);
temperature=temperature(keep);
pressure=object.PressureLookup(density,temperature);

% manage output
Nout=nargout();
if Nout > 0
    varargout{1}=density;
    varargout{2}=temperature;
    varargout{3}=pressure;
    if Nout > 3
        convert=SLAM.Shock.JumpConditions();
        convert.InitialDensity=rho0;
        convert.InitialPressure=P0;
        out=calculate_up_Us(convert,[1./density(:) pressure(:)]);
        varargout{4}=reshape(out(:,1),size(density)); % up
        varargout{5}=reshape(out(:,2),size(density)); % Us
    end
    return
end

figure();
axes('Box','on','NextPlot','add','OuterPosition',[0 0.5 1 0.5]);
plot(density,temperature);
xlabel('Density (Mg/m^3)');
ylabel('Temperature (K))');
line(rho0,T0,'Marker','.','Color','k');

axes('Box','on','NextPlot','add','OuterPosition',[0 0.0 1 0.5]);
plot(pressure,temperature);
xlabel('Pressure (GPa)');
ylabel('Temperature (K))');
line(P0,T0,'Marker','.','Color','k');


end