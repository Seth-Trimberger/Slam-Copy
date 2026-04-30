% plot Visualize spectral function(s)
%
% This method plots spectral functions in a new figure.
%    plot(object,wavelength); 
% Optional input "wavelength" indicates where each spectral function
% (elements of "object") is evaluated.  Waypoints are used when this input
% is empty/omitted.
%
% See also SpectralFunction, combine, define, integrate
%
function plot(object,wavelength)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(wavelength)    
    left=+inf;
    right=-inf;
    for n=1:numel(object)
        left=min(left,object(n).Waypoints(1));
        right=max(right,object(n).Waypoints(end));
    end    
   width=right-left;
   extra=0.05;
   left=left-width*extra;
   left=max(left,0);
   right=right+width*extra;
   points=1000;
   wavelength=linspace(left,right,points);
else
    assert(isnumeric(wavelength) && all(wavelength >= 0)...
        && all(isfinite(wavelength)),'ERROR: invalid wavelength request');
end

figure();
axes('NextPlot','add','Box','on');
label=cell(size(object));
for n=1:numel(object)
    plot(wavelength,object(n).Function(wavelength));
    label{n}=[object(n).Name ' ' object(n).FunctionLabel];
end
xlabel(object(1).SpectrumLabel);
ylabel('Value');
legend(label,'Location','best');

end