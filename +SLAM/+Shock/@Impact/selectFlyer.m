% UNDER CONSTRUCTION
% 
%    selectFlyer(object,material);
%
%    selectFlyer(object,density0,param);
%    selectFlyer(object,density0,param,type);
%    selectFlyer(object,density0,shockFcn);
%
% See also Impact, defineShockSpeed, lookupMaterial
% 
% 
function selectFlyer(object,varargin)

% manage input
Narg=numel(varargin);
assert(Narg > 0,'ERROR: insufficient input');
if Narg == 1
    try
        [rho0,param]=object.lookupMaterial(varargin{1});
        shockFcn=object.defineShockSpeed(param,'polynomial');
    catch ME
        throwAsCaller(ME);
    end
else
    rho0=varargin{1};
    assert(isnumeric(rho0) && isscalar(rho0) && (rho0 > 0),...
        'ERROR: invalid flyer density');
    if isa(varargin{2},'function_handle')
        shockFcn=varargin{2};
    else
        try
            shockFcn=object.defineShockSpeed(varargin{2:end});
        catch ME
            throwAsCaller(ME)
        end
    end
end

% store flyer data
object.Flyer.Density=rho0;
object.Flyer.ShockFcn=shockFcn;

end