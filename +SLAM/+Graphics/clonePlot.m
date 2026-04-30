% clonePlot Copy plot in a new figure
%
% This function copies a specified plot in a new figure.
%    new=clonePlot(target);
% Optional input "target" indicates the graphic handle to be copied.  When
% this is omitted or empty, the current axes is used.  An error is
% generated if no plot is available.
%
% See also SLAM.Graphics
%
function new=clonePlot(target)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(target)
    target=get(groot(),'CurrentFigure');
%elseif strcmpi(target,'choose')
%   commandwindow();
%   fprintf('Click on the plot to be cloned, then press return ')
else
    assert(ishandle(target),'ERROR: invalid request');
end

fig=ancestor(target,'figure');
target=get(fig,'CurrentAxes');
assert(ishandle(target),'ERROR: no plot available to clone');

% create full size plot in new figure
fig=figure('WindowStyle','normal');
new=copyobj(target,fig);
set(new,'Units','normalized','OuterPosition',[0 0 1 1]);

end