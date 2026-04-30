% plot Plot melt curve
%
% This method plots the current melt curve in a new figure window:
%    plot(object);
% or in a specified target axes.
%    plot(object,target);
% The first example creates a line in new axes with labels, while the
% second example adds a line without further modifications to the existing
% axes.
%
% Requesting an output argument:
%    h=plot(object,...);
% returns the graphic handle for the plotted line.
%
% See also MeltCurve, calculate
%
function varargout=plot(object,target)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(target)
    figure();
    target=axes('Box','on');
    xlabel('Pressure (GPa)');
    ylabel('Temperature (K)');
else
    assert(ishandle(target) && contains(target.Type,'axes'),...
        'ERROR: invalid target axes');
end

% plot melt line
for n=1:numel(object)
    new=line(object(n).Pressure,object(n).Temperature,...
        'Parent',target,'Color','k');
    if n == 1
        h=repmat(new,size(object));
    else
        h(n)=new;
    end
end

% manage output
if nargout() > 0
    varargout{1}=h;
end

end