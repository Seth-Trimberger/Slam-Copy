% etendue Calculate optical throughput
%
% This function calculates the optical throughput, also known as etendue,
% of a circular region.
%    G=etendue(d,NA);
% Optional input "d" defines the collection diameter (in millimeters), with
% a default value of 1.  Optional input "NA" defines the numerical
% aperture, with a default value of 1.  One or more values for each input
% may be specified with the following rules.
%    -Collection diameters must never be negative.
%    -Numerical apertures must be in the range [0 1].
%    -The number of requested diameters and numerical apertures must either
%    be the same or one of them must be a scalar.
% The output "G" is an array of etendue values in units of square
% millimeters times steradians.
%
% Calling this function without an output request:
%    etendue(d,NA);
% prints a table of results in the command window.
%
% See also SLAM.Pyrometry
%
function varargout=etendue(diameter,NA)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(diameter)
    diameter=1; % mm
else
    assert(isnumeric(diameter) && all(diameter >= 0),...
        'ERROR: invalid diameter');
end

if (Narg < 2) || isempty(NA)
    NA=1;
else
    assert(isnumeric(NA) && all(NA >= 0) && all(NA <= 1),...
        'ERROR: invalid numerical aperture');
end

% reconcile inputs
if isscalar(diameter)
    diameter=repmat(diameter,size(NA));
elseif isscalar(NA)
    NA=repmat(NA,size(diameter));
else
    assert(numel(diameter) == numel(NA),...
        'ERROR: diameter and numerical aperture are not consistent');
end

% manage output
G=(pi*diameter.*NA/2).^2;
if nargout() > 0
    varargout{1}=G;
    return
end
fprintf('%15s%10s%15s\n','Diameter','NA','Etendue');
fprintf('%15s%10s%15s\n','(mm)','(-)','(mm^2*sr)');
for n=1:numel(diameter)
    fprintf('%15.3f%10.3f%15g\n',diameter(n),NA(n),G(n));
    commandwindow();
end

end