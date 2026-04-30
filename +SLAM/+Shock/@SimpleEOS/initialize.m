% UNDER CONSTRUCTION
% 
% 
% See also SimpleEOS
%
function initialize(object,Pmax,showplots)

% manage input
Narg=nargin();

if (Narg < 2) || isempty(Pmax)
    Pmax=1e12; % Pa
else
    assert(isnumeric(Pmax) && isscalar(Pmax)...
        && isfinite(Pmax) && (Pmax > 0),...
        'ERROR: invalid maximum pressure');
end

if (Narg < 3) || isempty(showplots) || strcmpi(showplots,'showplots')
    showplots=true;
elseif strcmpi(showplots,'noplots')
    showplots=false;
else
    error('ERROR: invalid plot mode');
end

% calculations
param=object.Parameters;
T0=param(1);
rho0=param(2);   v0=1/rho0;
c0=param(3);
a=param(4);
cv=param(5);
gamma=param(6);

    function P=pressureFcn(eta)
        P=rho0*c0^2*eta./(1-a*eta).^2;
    end
    function dydx=kernelFcn(eta,~)
        dydx=exp(-gamma*eta).*eta.^2./(1-a*eta).^3;
    end
    function [value,isterminal,direction]=eventFcn(eta,~)
        value=Pmax-pressureFcn(eta);
        isterminal=1;
        direction=0;
    end
options=odeset('Events',@eventFcn,'RelTol',1e-9,'AbsTol',1e-9);
[eta,Delta]=ode45(@kernelFcn,[0 1/a],0,options);
TH=(T0+a*c0^2/cv.*Delta).*exp(gamma*eta);
PH=pressureFcn(eta);

b=cv*gamma/v0;
PR=PH-b*TH;
object.Reference=griddedInterpolant(eta,PR,'linear','linear');

if ~showplots
    return
end

% generate plots
fig=SLAM.Graphics.SimpleFigure();
set(fig,'Units','inches','PaperPositionMode','auto','Position',[0 0 7 9]);
movegui(fig,'northeast');

up=(sqrt(rho0^2*c0^2+4*rho0*a*Pmax)-rho0*c0)/(2*rho0*a);
up=linspace(0,up,1000);
Us=c0+a*up;
P=rho0*Us.*up;
v=(Us-up)./Us/rho0;

%subplot(2,2,1);
t=tiledlayout(3,2);
t.Padding='compact';
t.TileSpacing='compact';

nexttile();
plot(up/c0,Us/c0,'r');
xlabel('Relative particle velocity');
ylabel('Relative shock velocity');

%subplot(2,2,2);
nexttile();
plot(up/1e3,P/1e9,'r');
xlabel('Particle Velocity (km/s)');
ylabel('Pressure (GPa)');

eta_max=1-rho0*v(end);
    function dydz=derivs(z,y) %#ok<INUSD>
        dydz=exp(-gamma*z)*z.^2./(1-a*z).^3;
    end
[eta,Delta]=ode45(@derivs,[0 eta_max],0,options);
TH=(T0+a*c0^2/cv.*Delta).*exp(gamma*eta);
PH=rho0*c0^2*eta./(1-a*eta).^2;
PR=PH-b*(TH-T0);
Ts=T0*exp(gamma*eta);
Ps=PR+b*(Ts-T0);

%subplot(2,2,3);
nexttile();
plot(1-eta,PH/1e9,'r',1-eta,Ps/1e9,'b',1-eta,PR/1e9,'k');
legend('Hugoniot','Isentrope','Isotherm');
xlabel('Relative volume')
ylabel('Pressure (GPa)')

nexttile();
plot(1-eta,(PH-PR)/1e9,'r',1-eta,(Ps-PR)/1e9,'b');
legend('Hugoniot','Isentrope');
set(gca,'YScale','log');
xlabel('Relative volume')
ylabel('Pressure difference (GPa)')

%subplot(2,2,4);
nexttile([1 2]);
plot(PH/1e9,TH,'r',Ps/1e9,Ts,'b',PR/1e9,repmat(T0,size(PR)),'k');
legend('Hugoniot','Isentrope','Isotherm','Location','best');
xlabel('Pressure (GPa)');
ylabel('Temperature (K)');
set(gca,'YScale','log')

end