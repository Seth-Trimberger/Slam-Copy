% plotCloud Plot data cloud
%
% This method plots a point cloud using 1-3 data columns.
%    plotCloud(object,column);
% Optional input "column" indicates which data columns are used for
% plotting.
%    -When one column is specified, these values are used on in the
%    vertical direction with row index in the horizontal direction. 
%    -When two columns are specified, the first is used for the horizontal
%    direction and the second for the vertical direction.
%    -When three columns are specified, these are used for the x, y, and z
%    direction (respectively).  
% The default column choice is based on number of available columns, up to
% a maximum value of three (1, [1 2], or [1 2 3]).  
%
% Each object element is plotted in a separate tab within the same figure.
%
% See also TAF
%
function plotCloud(object,column)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(column)
    column=[];
else
    assert(isnumeric(column) && all(column >= 1) ...
        && any(numel(column) == 1:3),'ERROR: invalid column index');
    column=ceil(column);
end

% create plot
fig=createFigure('Name','TAF plotCloud');
tg=uitabgroup(fig,'Units','normalized','Position',[0 0 1 1]);
for n=1:numel(object)
    % verify file
    try
        info=object.Info;
    catch ME
        throwAsCaller(ME);
    end
    assert(any(info.Dimensions == 2),...
        'ERROR: cannot plot cloud points for %d dimensions',...
        info.Dimensions);
    if info.TypeCode == 1
        warning('TAF:TypeCode',...
            'This method is not meant for use with column arrays');
    end
    % read and plot array
    try
        data=read(object(n));
        cols=size(data,2);
        k=column;
        if isempty(k)
            k=1:min(cols,3);
        end
        temp=data(:,k);
    catch ME
        throwAsCaller(ME);
    end
    t=uitab(tg,'Title',object(n).Name);
    axes(t,'Box','on');  
    switch numel(k)
        case 1
            plot(temp,'.');
            xlabel('Index');
            ylabel(sprintf('Column %d',k));
        case 2
            plot(temp(:,1),temp(:,2),'.');
            xlabel(sprintf('Column %d',k(1)));
            ylabel(sprintf('Column %d',k(2)));
        case 3
            plot3(temp(:,1),temp(:,2),temp(:,3),'.');
            xlabel(sprintf('Column %d',k(1)));
            ylabel(sprintf('Column %d',k(2)));
            zlabel(sprintf('Column %d',k(3)));
    end
end

end