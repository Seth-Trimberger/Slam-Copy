% define Define melt curve parameters
% 
% This method defines melt curve parameters.  This may be done all at once:
%    define(object,param);   % param = [T0 b P0 P1 P2]
% with a 4-5 element parameter array.  The optional fifth element is
% automatically set to infinity when omitted.  Specific parameters can also
% be defined by their symbol.
%    define(object,symbol,value);
% Valid symbols include 'T0', 'b', 'P0', 'P1', and 'P2' (case insensitive).
%
% NOTE: this method automatically invokes the calculate method so that the
% Temperature property is always consistent with the current parameter
% state.  The Pressure property remains unchanged unless the P0 is changed,
% in which case the default pressure range (which depends on P0) is used.
%
% See also MeltCurve, calculate, plot
%
function define(object,varargin)

N=numel(varargin);
previous=object.Parameter;
switch N
    case 0
        param=[354.8 1/3.0 2.17 1.253 inf]; %  default is Datchi ice VII
        fprintf('Defaulting to the Datchi VII melt line');
    case 1
        param=varargin{1};
        ERRMSG='ERROR: invalid parameter array';
        assert(isnumeric(param),ERRMSG)
        if numel(param) == 4
            param(end+1)=inf;
        else
            assert(numel(param) == 5,'ERROR: invalid parameter array')
        end
    case 2
        symbol=varargin{1};
        assert(ischar(symbol) || isStringScalar(symbol),...
            'ERROR: invalid symbol');
        value=varargin{2};
        param=previous;
        assert(isnumeric(value),'ERROR: invalid parameter');
        if strcmpi(symbol,'T0')
            param(1)=value;
        elseif strcmpi(symbol,'b')
            param(2)=value;
        elseif strcmpi(symbol,'P0')
            param(3)=value;
        elseif strcmpi(symbol,'P1')
            param(4)=value;
        elseif strcmpi(symbol,'P2')
            param(5)=value;
        else
            error('ERROR: "%s" is not a valid parameter symbol',symbol);
        end
    otherwise
        error('ERROR: too many input arguments');
end

% verify parameters
q=param(1);
assert(isfinite(q) && (q > 0),...
    'ERROR: invalid reference temperature (T0)');
q=param(2);
assert(isfinite(q) && (q > 0),'ERROR: invalid exponent (b)');
q=param(3);
assert(isfinite(q) && (q > 0),'ERROR: invalid reference pressure (P0)');
q=param(4);
assert(isfinite(q) && (q > 0),...
    'ERROR: invalid primary pressure scale (P1)');

% manage input
object.Parameter=param;

P=object.Pressure;
if isempty(P) || (previous(3) ~= param(3))
    calculate(object);
else
    calculate(object,P);
end

end