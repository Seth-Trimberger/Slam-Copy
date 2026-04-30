% Voigt Evaluate Voigt peak
%
% This function evaluates the Voigt peak at specified locations.
%    y=Voigt(x,param);
% The input "x" defines the evaluation grid, which runs -5 to +5 in 1000
% steps by default.  The input "param" defines nonlinear parameters
% associated with the peak [center sigma gamma], using [0 1 1] by default.
%
% Calling this function with no output:
%    Voigt(x,param);
% plots the peak in a new figure window.
%
% See also SLAM, Spectroscopy
%
function varargout=Voigt(x,param)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(x)
    x=linspace(-5,5,1000);
else
    assert(isnumeric(x),'ERROR: invalid evaluation grid');
end


if (Narg < 2) || isempty(param)
    param=[0 1 1];
else 
    assert(isnumeric(param) && (numel(param) == 3),...
        'ERROR: invalid parameter array');
end

% evaluate peak function
x0=param(1);
sigma=param(2);
assert(sigma > 0,'ERROR: gaussian width sigma must be greater than zero');
gamma=param(3);

z=(x-x0+1i*gamma)/(sigma*sqrt(2));
y=real(SLAM.Math.Faddeeva(z));

z0=1i*gamma/(sigma*sqrt(2));
y0=real(SLAM.Math.Faddeeva(z0));
y=y/y0;

% manage output
if nargout() > 0
    varargout{1}=y;
    return;
end
SLAM.Graphics.SimpleFigure();
plot(x,y);
xlabel('x');
ylabel('y');
label=sprintf('Voig peak using [%g %g %g]',param);
title(label);


end