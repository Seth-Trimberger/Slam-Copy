% evaluate Perform rational interpolation
%
% This method performs interpolation at specified locations.
%   y=evaluate(object,x);
% Mandatory input "x" (numeric array) indicates where interpolation is
% performed to determine output "x".  Locations outside the specified grid
% return NaN, i.e. there is no extrapolation.
% 
% See also kinterp1
%
function y=evaluate(object,x)

assert(isscalar(object),...
    'ERROR: interpolation must be done one element at a time');

% manage input
assert((nargin() > 1) && ~isempty(x),...
    'ERROR: evaluation point(s) must be specified');
assert(isnumeric(x) && isreal(x) && all(isfinite(x)),...
    'ERROR: invalid evaluation point(s)');
y=nan(size(x));
x=x(:);

% manage points
xmin=object.Grid(1);
xmax=object.Grid(end);
active=(x >= xmin) & (x <= xmax);
y(active)=interpolate(object,x(active));

end

function y=interpolate(object,x)

N=object.Points;
i=object.IndexFcn(x);
i(i == N)=N-1;

S=object.Parameter(i,1);
C1=object.Parameter(i,2);
C2=object.Parameter(i,3);
xL=object.Grid(i);
xR=object.Grid(i+1);
y=object.Data(i);

k=(i == 1);
y(k)=y(k)+(x(k)-xL(k)).*(S(k)-C2(k).*(xR(k)-x(k)));

k=(i > 1) & (i < N-1);
mu1=abs(C2(k).*(xR(k)-x(k)));
mu2=abs(C1(k).*(x(k)-xL(k)));
B=(C1(k).*mu1+C2(k).*mu2)./(mu1+mu2);
y(k)=y(k)+(x(k)-xL(k)).*(S(k)-B.*(xR(k)-x(k)));

k=(i == N-1);
y(k)=y(k)+(x(k)-xL(k)).*(S(k)-C1(k).*(xR(k)-x(k)));

end