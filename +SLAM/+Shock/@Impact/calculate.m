% UNDER CONSTRUCTION
%
% See also Impact
%
function varargout=calculate(object,quantity,value)


assert(~isempty(object.Flyer.ShockFcn) || ~isempty(object.Sample.ShockFcn),...
    'ERROR: cannot calculate until flyer and sample are selected');

% manage input
assert(nargin() == 3,'ERROR: invalid number of inputs');

assert(ischar(quantity) || isStringScalar(quantity),...
    'ERROR: invalid calculation quantity');

assert(isnumeric(value) && isscalar(value) && isfinite(value),...
    'ERROR: invalid calculation value');

% set up functions
options=optimset('TolX',object.Tolerance,'TolFun',object.Tolerance);
data=object.Sample;
PS=@(u) data.Density*data.ShockFcn(u).*u;
data=object.Flyer;
PF=@(u,v) data.Density*data.ShockFcn(v-u).*(v-u);

report=struct('vf',nan,'u',nan,'P',nan,'Us',nan);

% perform requested calculation
if strcmpi(quantity,'FlyerVelocity')
    assert(value > 0,'ERROR: flyer velocity must be a number > 0');
    z=@(u) PF(u,value)-PS(u);
    u=fzero(z,[0 value],options);    
    report.vf=value;
    report.u=u;
    report.P=PS(u);
    report.Us=object.Flyer.ShockFcn(u);
elseif strcmpi(quantity,'ParticleVelocity')
    assert(value > 0,'ERROR: particle velocity must be a number > 0');
    report.u=value;
    report.Us=object.Sample.ShockFcn(value);
    report.P=Ps(value);
    report.vf=fzero(@(u) PF(u,value)-report.P,value,options);
elseif strcmpi(quantity,'Pressure')
    assert(value > 0,'ERROR: pressure must be a number > 0');
    report.P=value;
    report.u=abs(fzero(@(u) PS(u)-value,0,options));
    report.Us=object.Sample.ShockFcn(report.u);
    report.vf=fzero(@(v) PF(report.u,v)-report.P,report.u,options);
elseif strcmpi(quantity,'SampleShock')
    assert(value > 0,'ERROR: sample shock velocity must be a number > 0');
    report.Us=value;
    report.u=fzero(@(u) object.Sample.ShockFcn(u)-value,0,options);
    report.P=PS(report.u);
    report.vf=fzero(@(v) PF(report.u,v)-report.P,report.u,options);
else
    error('ERROR: "%s" is not a supported calculation quantity',quantity);
end
object.Flyer.Anchor=report.vf;

% manage output
if nargout() > 0
    varargout{1}=report;
    return
end
fprintf('Flyer velocity = %g km/s\n',report.vf);
fprintf('Particle velocity = %g km/s\n',report.u);
fprintf('Pressure = %g GPa\n',report.P);
fprintf('Sample shock velocity = %g km/s\n',report.Us);

end