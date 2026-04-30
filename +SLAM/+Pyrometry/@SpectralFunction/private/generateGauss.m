function generateGauss(param,object)

if numel(param) == 2
    param(3)=1;
end
assert((numel(param) == 3) && all(param >= 0) && all(isfinite(param)),...
    'ERROR: invalid parameter array');

center=param(1);
width=param(2);
amplitude=param(3);
object.Function=@(x) amplitude*exp(-(x-center).^2/(2*width));
NumberWaypoints=10;
object.Waypoints=linspace(center-3*width,center+3*width,NumberWaypoints);

end