% UNDER CONSTRUCTION
% plotHugoniot Show principal Hugoniot
%
% [up Us rho P TH]
%
% See also SimpleEOS
%
function varargout=plotHugoniot(object,P_max)

% manage input
if (nargin() < 2) || isempty(P_max)
    P_max=100; % GPa
else
    assert(isnumeric(P_max) && isfinite(P_max) && (P_max > 0), ...
        'ERROR: invalid maximum pressure');
end

% extract parameters
rho0=object.Parameters(1);
c0=object.Parameters(2);
s=object.Parameters(3);
cv=object.Parameters(4);
Gamma0=object.Parameters(5);

% determine maximum particle velocity
    function Us=particle2shock(up)
        Us=c0+s*up;
    end
    function P=particle2pressure(up)
        Us=calculateShockVelocity(up);
        P=rho0*Us.*up;
    end
    function rho=velocities2density(up,Us)
        rho=rho0*Us./(Us-up);
    end
up_max=fzero(@(x) P_max-calculatePressure(x),0);
%up_max=(sqrt(c0^2+4*s*Pmax/rho0)-c0)/(2*s); % quadratic equation approach
Us_max=calculateShockVelocity(up_max);
rho_max=calculateDensity(up_max,Us_max);
eta_max=1-rho0/rho_max;

% calculate temperature
    function P=strain2pressure(eta)
        P=rho0*c0^2*eta./(1-s*eta)^.2;
    end
    function out=kernel(eta)
        out=exp(-Gamma0*eta).*eta.^2./(1-s*eta).^3;
    end
eta_max=fzero(@(x) P_max-strain2pressure(x),0);
[eta,T]=integral(@kernel,0,eta_max);

P=strain2pressure(eta);


up=linspace(0,up_max,1000);
Us=c0+s*up;
density=rho0*Us./(Us-up);
pressure=rho0*Us.*up;
volume=1./density;

figure('WindowStyle','normal');
subplot(2,2,1);
plot(up,Us);
xlabel('Particle velocity (km/s)');
ylabel('Shock velocity (km/s)');

subplot(2,2,2);
plot(up,pressure);
xlabel('Particle velocity (km/s)');
ylabel('Pressure (GPa)');

subplot(2,2,3);
plot(volume,pressure);
xlabel('Specific volume (cc/g)');
ylabel('Pressure (GPa)');

subplot(2,2,4);
plot(density,pressure);
xlabel('Density (g/cc)');
ylabel('Pressure (GPa)');

%    function P=calculatePressure(eta)
%        P=rho0*c0^2*eta./(1-s*eta).^2;
%    end
%eta_max=fzero(@(x) Pmax-calculatePressure(x),[0 1/s-10*eps()]);

% manage output
if nargout() > 0
    varargout{1}=data;
end

end