% defineShockSpeed Define shock speed function
%
% This *static* method defines a shock speed function.
%    speedFcn=Impact.defineShockSpeed(param,type);
% Mandatory input "param" specifies numerical parameters for the shock
% speed function.  Optional input "type" indicates the function used with
% those parameters to generate the output function handle "speedFcn".  The
% default function type is 'polynomial'.
%
% Polynomial functions define shock speed in terms of particle velocity.
%    Us=p1+p2*up+p3*up^2+...
% Function paramaters are specified in ascending power.  For example, the
% standard linear model is defined as [c0 s], where c0 is the ambient sound
% speed.
%
% The universal liquid Hugonoiot (type = 'ulh') depends on four numerical
% parameters [c0 a b s] used in the following manner.
%    (Us/c0) = a + (1-a) exp(-b up/c0) + b (up/c0)
%
% See also Impact
%
function speedFcn=defineShockSpeed(param,type)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(param)
    param=[1 0];
    fprintf('Using default polynomial parameters [%g %g] \n',param);
end
assert(isnumeric(param),'ERROR: invalid parameter array')

if (Narg < 2) || isempty(type)
    type='polynomial';
else
    assert(ischar(type) || isStringScalar(type),...
        'ERROR: invalid function type');
end

%
switch lower(type)
    case 'polynomial'
        assert(numel(param) >= 2,...
            'ERROR: polynomial function requires 2+ parameters');
        assert(param(1) > 0,'ERROR: ambient sound speed must be > 0');
        param=reshape(param(end:-1:1),1,[]);
        speedFcn=@(up) polyval(param,up);
    case 'ulh'        
        assert(numel(param) == 4,...
            'ERROR: universal liquid Hugoniot uses four parameters');
        assert(param(1) > 0,'ERROR: ambient sound speed must be > 0');
        c0=param(1);
        a=param(2);
        b=param(3);
        s=param(4);
        speedFcn=@(up) a*c0+(1-a)*c0*exp(-b*up/c0)+s*(up/c0);
    otherwise
        error('ERROR: unknown function type');
end

end