% calculate Calculate melt curve temperatures
%
% This method calculates temperatures on the melt curve.  Pressure values
% used for this calculation can be specified explicitly:
%    calculate(object,P);
% or in terms of the maximum value (starting from P0) and the number of
% evaluation points.
%    calculate(object,Pmax,points);
% Calling this method with no inputs:
%    calculate(object);
% causes pressure to be 1000 uniformly spaced values from P0 to 10*P0.
%
% See also MeltCurve, define, plot
%
function calculate(object,varargin)

T0=object.Parameter(1);
b=object.Parameter(2);
P0=object.Parameter(3);
P1=object.Parameter(4);
P2=object.Parameter(5);

% manage input
N=numel(varargin);
switch N
    case 0
        P=linspace(1,10,1000)*P0;
    case 1
        P=varargin{1};
        assert(isnumeric(P),'ERROR: invalid pressure array');
    case 2
        Pmax=varargin{1};
        assert(isnumeric(Pmax) && isscalar(Pmax) && (Pmax > P0),...
            'ERROR: maximum pressure must be a number greater than reference value');
        N=varargin{2};
        assert(isnumeric(N) && isscalar(N) && (N >= 3),...
            'ERROR: number of points must be a number >= 3');
        N=ceil(N);
        P=linspace(P0,Pmax,N);
    otherwise
        error('ERROR: too many input arguments');

end

% calculate temperature
Delta1=(P-P0)/P1;
T=T0*(1+Delta1).^b;
if isfinite(P2)
    Delta2=(P-P0)/P2;
    T=T.*exp(-Delta2);
end

object.Pressure=P;
object.Temperature=T;

end