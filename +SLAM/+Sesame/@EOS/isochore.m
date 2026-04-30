% isochore Calculate isochore(s)
%
% This method calculates pressure-temperature curves for constant density.
% These curves can be automatically plotted:
%    isochore(object,density);
% or returned as two-dimensional arrays.
%    [rho,T,P]=isochore(object,density);
% Optional input "density" defines the isochore(s) of interest.  The
% reference density is used when this input is empty/omitted.
%
% See also EOS, isotherm
%
function varargout=isochore(object,density)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(density)
    density=object.ReferencePoint(1);
else
    assert(isnumeric(density) && all(density(:) >= 0),...
        'ERROR: invalid density');
end


% perform calculations
M=numel(density);
density=reshape(density,M,1);
temperature=object.Temperature(1,:);
N=numel(temperature);
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
label=cell(M,1);
for m=1:M
    new=plot(temperature(m,:),pressure(m,:));
    new.Tag=sprintf('\\rho= %g Mg/m^3',density(m,1));
    label{m}=new.Tag;
    if m == 1
        h=repmat(new,[M 1]);
    else
        h(m)=new; 
    end
end
xlabel('Temperature (K)');
ylabel('Pressure (GPa)');
legend(h,label,'Location','best');

end