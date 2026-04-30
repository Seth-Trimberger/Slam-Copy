% UNDER CONSTRUCTION
%
% See also Impact
%
function plot(object)

assert(~isempty(object.Flyer.ShockFcn) || ~isempty(object.Sample.ShockFcn),...
    'ERROR: cannot plot until flyer and sample are selected');

figure();
options=optimset('TolX',object.Tolerance,'TolFun',object.Tolerance);

data=object.Flyer;
a=data.Anchor;
P=@(u) data.Density*data.ShockFcn(a-u).*(a-u);
z=@(x) object.Pmax-P(x);
final=fzero(z,a,options);
uF=linspace(a,final,object.Points);
PF=P(uF);

data=object.Sample;
a=data.Anchor;
P=@(u) data.Density*data.ShockFcn(u).*u;
z=@(x) object.Pmax-P(x);
final=fzero(z,a,options);
final=abs(final);
uS=linspace(a,final,object.Points);
PS=P(uS);

plot(uS,PS,uF,PF);
xlabel('Particle velocity (km/s)');
ylabel('Pressure (GPa)');
legend('Sample','Flyer','Location','best');

end