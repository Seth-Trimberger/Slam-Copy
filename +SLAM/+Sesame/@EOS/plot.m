% plot Plot table data
%
% This method plots information from the Sesame table.  Tabulated values
% are shown by contour plots.
%    plot(object,type,levels);
% Optional input "type" indicates the tabulated variable to be plotted.
% Supported values include 'pressure' (default), 'energy', 'helmholtz', and
% 'entropy'.  Optional input "levels" indicate either the number of
% contours (default is 10) or specific contour values.  A repeated value,
% such as [P1 P1], distinguishes a single contour at specified level from
% specified number of contours.
%
% Density-temperature grid locations can also be plotted.
%    plot(object,'grid');
%
% All plots are generated in a new figure window.  Requesting an output:
%    h=plot(object,...);
% returns the graphic handle for the contour/line object created in that
% figure.
% 
% See also EOS
%
function varargout=plot(object,type,levels)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(type)
    type='pressure';
else
    assert(ischar(type) || isStringScalar(type),...
        'ERROR: invalid plot type');
end

if (Narg < 3) || isempty(levels)
    levels=10;
else
    assert(isnumeric(levels),'ERROR: invalid plot levels')
end

% generate plot
fig=figure();

x=object.Density(:,1);
y=object.Temperature(1,:);
switch lower(type)
    case 'pressure'
        z=transpose(object.Pressure);
        label=sprintf('Pressure (GPa) for %s',object.Name);
        format='%g GPa';
    case 'energy'
        z=transpose(object.Energy);
        label=sprintf('Specific energy (MJ/kg) for %s',object.Name);
        format='%g MJ/kg';
    case 'helmholtz'
        z=transpose(object.Helmholtz);
        label=sprintf('Specific Helmholtz free energy (MJ/kg) for %s',object.Name);
        format='%g MJ/kg';
    case 'entropy'
        z=transpose(object.Entropy);
        label=sprintf('Specific entropy (MJ/kg*K) for %s',object.Name);
        format='%g MJ/kg*K';
    case {'grid'}
        temp=object.PressureLookup.GridVectors;
        x=temp{1};
        M=numel(x);        
        y=temp{2};
        N=numel(y);
        x=repmat(x,[1 N]);
        y=repmat(y,[M 1]);
        x=x(:);
        y=y(:);
        z=[];
        h=plot(x,y,'ko');
        h.MarkerFaceColor=h.Color;
        label=sprintf('Grid points for %s',object.Name);
    otherwise
        close(fig);
        error('ERROR: %s is not a valid plot type',type);
end

if ~isempty(z)
    [~,h]=contour(x,y,z,levels,'LabelFormat',format);
    % color bar versus inline labels
end
xlabel('Density (Mg/m^3)');
ylabel('Temperature (K)');
title(label);

% manage output
if nargout() > 0
    varargout{1}=h;
end

end