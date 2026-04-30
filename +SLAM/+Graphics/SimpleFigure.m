% SimpleFigure Create a simple MATLAB figure
%
% This function creates a simple MATLAB figure:
%    fig=SimpleFigure();
% using normal window style, no menu bar, and the standard tool bar.
%
function fig=SimpleFigure()

%fig=figure('WindowStyle','normal');
fig=uifigure('HandleVisibility','on',...
    'Toolbar','figure','MenuBar','none');

end