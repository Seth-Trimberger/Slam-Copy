% integrate Integrate spectral function over all wavelengths
%
% This methods integrates the spectral function over all wavelengths.
%    value=integrate(object);
% The output "value" is a numeric array of the same size as "object".
% Waypoints stored in the object are used to confine integration between
% zero and infinite wavelength.
%
% A secondary function can be incorporated with the integration with an
% additional input.
%    value=integrate(object,fcn);
% The function handle "fcn" is multiplied with the spectral function during
% integration.  For example, the first moment of the spectral function is
% is calculated as follows.
%    I0=integrate(object);
%    I1=integrate(object,@(x) x)/I0;
% 
% See also SpectralFunction, combine, define
%
function value=integrate(object,arg)

% manage input
if (nargin() < 2) || isempty(arg)
    modify=false();
else
    modify=true();
end

% perform integration(s)
value=nan(size(object));
for n=1:numel(object)
    kernel=object(n).Function;
    if modify
        kernel=@(x) kernel(x).*arg(x);
    end
    value(n)=integral(kernel,0,inf,...
        'Waypoints',object(n).Waypoints,...
        'AbsTol',object(n).Tolerance.Absolute,...
        'RelTol',object(n).Tolerance.Relative);
end
    
end