function generateSquare(param,object)

if numel(param) == 2
    param(3)=1;
end
assert((numel(param) == 3) && all(param >= 0) && all(isfinite(param)),...
    'ERROR: invalid parameter array');

bound=uniquetol(param(1:2),object.Tolerance.Wavelength);
assert(numel(bound) == 2,...
    'ERROR: wavelength bounds not sufficiently unique');
left=bound(1);
right=bound(2);
amplitude=param(3);
object.Function=@(x) amplitude*double((x >= left).*(x <= right));
NumberWaypoints=10;
object.Waypoints=linspace(left,right,NumberWaypoints);

end