% Gaussian Evaluate Gaussian peak
%
% This function evalutes a Gaussian peak at specified locations.
%    y=Gaussian(x,param);
% The input "x" defines the evaluation grid, which runs -5 to +5 in 1000
% steps by default.  The input "param" defines nonlinear parameters
% associated with the peak [center sigma], using [0 1] by default.
%
% Calling this function with no output:
%    Gaussian(x,param);
% plots the peak in a new figure window.
%
% See also SLAM.Spectroscopy
%
function varargout=Gaussian(x,param)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(x)
    x=linspace(-5,5,1000);
else
    assert(isnumeric(x),'ERROR: invalid evaluation grid');
end


if (Narg < 2) || isempty(param)
    param=[0 1];
else 
    assert(isnumeric(param) && (numel(param) == 2),...
        'ERROR: invalid parameter array');
end

% evaluate peak function
x0=param(1);
sigma=param(2);
y=exp(-(x-x0).^2/(2*sigma^2));

% manage output
if nargout > 0
    varargout{1}=y;
    varargout{2}=x;
    return
end

SLAM.Graphics.SimpleFigure();
plot(x,y);
xlabel('x');
ylabel('y');
label=sprintf('Gaussian peak using [%g %g]',param);
title(label);

end