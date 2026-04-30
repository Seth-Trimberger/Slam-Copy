function fig=createFigure(varargin)

fig=figure('HandleVisibility','on','NumberTitle','on',...
    'ToolBar','figure');
set(fig,varargin{:});

end