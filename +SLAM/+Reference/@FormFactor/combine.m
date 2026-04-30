% UNDER CONSTRUCTION
%
% See also FormFactor
% 
function object=combine(form,rho,fraction)

persistent NA
if isempty(NA)
    info=SLAM.Reference.CODATA('avogadro');
    NA=info.Value;
end

% verify input
Narg=nargin();
assert(Narg >= 2,'ERROR: insufficient input');

N=numel(form);
assert(N > 1,'ERROR: cannot combine a scalar form factor');

assert(isnumeric(rho) && isscalar(rho) && (rho > 0),...
    'ERROR: invalid mass density');

if (nargin < 3) || isempty(fraction)
    fraction=1;
end
if isscalar(fraction)
    fraction=repmat(fraction,size(form));
else
    assert(numel(fraction) == N,...
        'ERROR: inconsistent number of units');
end

% combine data on a common grid
xi=[];
for n=1:N
    xi=[xi; form(n).Data(:,1)]; %#ok<AGROW>
end
xi=unique(xi);

data=zeros(numel(xi),3);
data(:,1)=xi;
MW=0;
for n=1:N
    x=form(n).Data(:,1);
    y1=form(n).Data(:,2);
    y2=form(n).Data(:,3);
    data(:,2)=data(:,2)+fraction(n)*interp1(x,y1,xi,'linear',nan);
    data(:,3)=data(:,3)+fraction(n)*interp1(x,y2,xi,'linear',nan);
    MW=MW+fraction(n)*form(n).AtomicMass;
end
rhoA=rho*NA/MW;
rhoA=rhoA*1e6; % convert 1/cc to 1/m^3

object=SLAM.Reference.FormFactor(data,rhoA,MW);

end