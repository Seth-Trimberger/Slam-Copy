% UNDER CONSTRUCTION
% lookupPressure Look up pressure (and its derivatives)
%
% This method looks up pressure at a specified temperature and specific
% volume.
%    P=lookupPressure(object,temperature,volume);
%
%
% Advanced mode:
%    [P,dPdT,dPdV]=lookupPressure(...);
% 
% See also SimpleEOS
%
function [P,dPdT,dPdV]=lookupPressure(object,temperature,volume)

%
param=object.Parameters;
T0=param(1);
rho0=param(2);   v0=1/rho0;
s=param(4);      vmin=v0*(1-1/s);
gamma=param(6);

% manage input
Narg=nargin();

if (Narg < 2) || isempty(temperature)
    temperature=T0;
else
    assert(isnumeric(temperature) ...
        && all(isfinite(temperature)) ...
        && all(temperature > 0),'ERROR: invalid temperature request');
end

if (Narg < 3) || isempty(volume)
    volume=v0;
else
    assert(isnumeric(vmin) && ...
        all(isfinite(vmin)) && ...
        all(volume > vmin),'ERROR: invalid specific volume request');
end

% calculations
b=cv*gamma/v0;
eta=1-volume/v0;
P=b*temperature+object.Reference(eta);

dPdT=b;

if nargout() < 3
    return
end

epsilon=eta*1e-3;
left=object.Reference(eta-epsilon);
right=object.Reference(eta+epsilon);
dPdV=(right-left)/(2*epsilon)/(-v0);

end