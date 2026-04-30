% isotherm Calculate isotherm(s)
%
% This method calculates pressure-density curves for constant temperature.
% These curves can be automatically plotted:
%    isotherm(object,temperature);
% or returned as two-dimensional arrays.
%    [rho,T,P]=isotherm(object,temperature);
% Optional input "temperature" defines the isotherm(s) of interest.  The
% reference temperature is used when this input is omitted or empty.
%
% See also EOS, isochore
%
function varargout=isotherm(object,temperature)
%
% manage input
Narg=nargin();
if (Narg < 2) || isempty(temperature)
    temperature=object.ReferencePoint(2);
else
    assert(isnumeric(temperature) && all(temperature(:) >= 0),...
        'ERROR: invalid temperature');
end

% perform calculations
N=numel(temperature);
temperature=reshape(temperature,1,N);
density=object.Density(:,1);
M=numel(density);
density=repmat(density,1,N);
temperature=repmat(temperature,M,1);
pressure=object.PressureLookup(density,temperature);

% manage output
if nargout() > 0
    varargout{1}=density;
    varargout{2}=temperature;
    varargout{3}=pressure;
    return
end

figure();
axes('Box','on','NextPlot','add');
label=cell(1,N);
for n=1:N
    new=plot(density(:,n),pressure(:,n));
    new.Tag=sprintf('T= %g K',temperature(1,n));
    label{n}=new.Tag;
    if n == 1
        h=repmat(new,[1 N]);
    else
        h(n)=new; 
    end
end
xlabel('Density (Mg/m^3)');
ylabel('Pressure (GPa)');
legend(h,label,'Location','best');

end