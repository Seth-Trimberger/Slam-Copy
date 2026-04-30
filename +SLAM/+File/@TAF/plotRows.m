% plotRows Plot array rows
%
% This method plots rows of a 2D array as lines in a new figure.
%    plotRows(object);
% These lines are automatically limited to the current region of interest.
% Each object element is plotted in a separate tab within the same figure.
%
% See also TAF, image, plotColumns, setROI
%
function plotRows(object)

% create plot
fig=createFigure('Name','TAF plotRows');
tg=uitabgroup(fig,'Units','normalized','Position',[0 0 1 1]);
for n=1:numel(object)
    % verify file
    try
        info=object(n).Info;
    catch ME
        throwAsCaller(ME);
    end
    assert(info.Dimensions == 2,...
        'ERROR: cannot plot "%s" because is has more than two dimensions',...
        object(n).Name);
    if info.TypeCode == 1
        warning('TAF:TypeCode',...
            'This method is not meant for use with column array in "%s"',...
            object(n).Name);
    end
    % read and plot array
    grid=cell(1,info.Dimensions);
    try
        [data,grid{:}]=read(object(n));
    catch ME
        throwAsCaller(ME);
    end
    t=uitab(tg,'Title',object(n).Name);
    axes(t,'Box','on');
    h=plot(grid{2},transpose(data));
    GridLabel=generateGridLabel(object);
    label=cell(1,numel(grid{1}));
    for col=1:numel(grid{1})
        label{col}=sprintf('%s = %g',GridLabel{1},col);
    end
    xlabel(GridLabel{2});
    ylabel('Data');
    legend(h,label,'Location','bestoutside');
end

end