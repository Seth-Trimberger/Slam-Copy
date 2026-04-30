% define Define spectral function
%
% This method provides several ways of defining the spectral function. A
% two-column array [wavelength value] can be used to explicitly denote the
% function over a finite range.
%    define(object,data);
% The input "data" is automatically sorted by the first column, eliminating
% non-unique values based on current Tolerance.Wavelength setting.  The
% function is assumed to be zero outside of the defined wavelength range.
% The name of a two-column text file (arbitrary header, white space
% delimited) containing the same information can be specified in place of
% the array.
%    define(object,file);
%
% Various spectral shape functions can be requested by name.
%    define(object,name,param);
% The input "name" must begin a dash ('-') and requires a numeric array
% "param" specific to the requested shape.
%    -The name '-square' indicates a uniform peak between two wavelength
%    bounds.  These bounds are specified as the first two parameter
%    elements [left right].  An optional third element controls function
%    amplitude between the bounds, defaulting to unity.
%    -The name '-gauss' indicates a Gaussian peak.  The center position and
%    peak width are specified as the first two parameter elements [x0 Lx].
%    An optional third element controls function amplitude between the
%    bounds, defaulting to unity.
%    -The name '-planck' indicates the Planck function, which describes
%    spectral radiance as a function of temperature (one parameter).  
%
% Custom functions can be requested by function handle.
%    define(object,fcn,waypoints);
% The input "fcn" must return an array of function values at any valid
% wavelength.  The input "waypoints" indicates wavelengths where "fcn" is
% not zero; at least two distinct locations are required.
%
% Calling this method with no specifications:
%    define(object);
% invokes the a square peak over the visible spectrum by default.
%
% See also SpectralFunction, combine, plot
%
function define(object,source,varargin)

assert(isscalar(object),...
    'ERROR: spectral functions must be defined one at at time');
object.IsDensity=false();

% manage input
if nargin() == 1
    fprintf('Defaulting to the visible spectrum\n');
    source='-square';
    varargin{1}=[400 700];
end

if isnumeric(source)
    processArray(source,object);
    object.Definition='array';
elseif ischar(source) || isStringScalar(source)
    if startsWith(source,'-')
        assert(~isempty(varargin),'ERROR: parameter array missing');
        param=varargin{1};
        assert(isnumeric(param),'ERROR: invalid parameter array');
        varargin=varargin(2:end);
        if strcmpi(source,'-square')
            generateSquare(param,object);
        elseif strcmpi(source,'-gauss')
            generateGauss(param,object);
        elseif strcmpi(source,'-planck')
            generatePlanck(param,object);
        else
            error('ERROR: "%s" shape is unknown');
        end
        object.Definition='shape';
    else
        try
            report=SLAM.File.readText(source);
            processArray(report.Data,object);
        catch ME
            throwAsCaller(ME);
        end
        object.Definition='file';
    end
elseif isa(source,'function_handle')
    assert(~isempty(varargin),...
        'ERROR: waypoints must be specified with custom handle');
    waypoints=varargin{1};
    assert(isnumeric(waypoints) && (all(waypoints >= 0) && all(isfinite(waypoints))), ...
        'ERROR: invalid waypoints');
    waypoints=uniquetol(waypoints,object.Tolerance.Wavelength);
    assert(numel(waypoints) >= 2,...
        'ERROR: at least two unique waypoints required');
    varargin=varargin(2:end);
    try
        [~]=source(waypoints);
    catch ME
        error('ERROR: invalid custom function');
    end
    object.Function=source;
    object.Waypoints=waypoints;
    object.Definition='custom';
else
    error('ERROR: invalid spectral definition');
end

% update density flag
if ~isempty(varargin) && strcmpi(varargin{1},'density')
    object.IsDensity=true();
end

if object.IsDensity
    object.FunctionLabel='Density (-/nm)';
end

% characterize function
area=integrate(object);
x0=integrate(object,@(x) x)/area;
L2=integrate(object,@(x) (x-x0).^2)/area;
object.Center=x0;
object.Width=sqrt(L2);

end

function processArray(data,object)

assert(ismatrix(data) && (size(data,2) == 2),...
    'ERROR: spectral array must be a two-column array');
data=sortrows(data,1);
wavelength=data(:,1);
assert(all(wavelength > 0),'ERROR: invalid wavelength value');
[wavelength,index]=uniquetol(wavelength,object.Tolerance.Wavelength);
assert(numel(wavelength) >= 2,...
    'ERROR: not enough unique wavelengths specified');
value=data(index,2);
assert(all(value >= 0),'ERROR: invalid spectral value');
wavelength(end+2)=0;
N=numel(wavelength);
index=[N-1 1:N-2 N];
wavelength=wavelength(index);
wavelength(1)=wavelength(2)-object.Tolerance.Wavelength;
if wavelength(1) < 0
    wavelength(1)=wavelength(2)/2;
end
wavelength(end)=wavelength(end-1)+object.Tolerance.Wavelength;
value(end+2)=0;
value=value(index);
object.Function=griddedInterpolant(wavelength,value,...
    'linear','nearest');
NumberWaypoints=10;
object.Waypoints=linspace(wavelength(1),wavelength(end),NumberWaypoints);

end