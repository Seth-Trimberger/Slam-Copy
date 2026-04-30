function generatePlanck(param,object)

persistent c1 c2 c3
if isempty(c1)
    value=SLAM.Pyrometry.lookupConstants();
    c1=value(1);
    c2=value(2);
    c3=value(3);
end

T=param(1);
assert((T > 0) && isfinite(T),'ERROR: invalid temperature');

object.Function=@planckFcn;
    function y=planckFcn(x)
        denom1=x.*x.*x.*x.*x; % faster than .^5
        arg=c2./(x*T);
        denom2=expm1(arg); % more accurate than exp(arg)-1
        y=c1./denom1./denom2;
    end

xm=c3/T;
ratio=0.01;
residual=@(x) object.Function(x)/object.Function(xm)-ratio;
left=fzero(residual,[0.2 1]*xm);
right=fzero(residual,[1 10]*xm);
%right=xm^2/left;
NumberWaypoints=10;
object.Waypoints=linspace(left,right,NumberWaypoints);
object.IsDensity=true();

end