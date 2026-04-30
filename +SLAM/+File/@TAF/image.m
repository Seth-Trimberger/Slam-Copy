% image Generate image
%
% This method generates an image from 2-3 dimensional arrays.
%    image(object,mode);
% Optional input "mode" controls how three-dimensional arrays are
% displayed. The default value 'scaled' interprets each image layer as its
% own intensity map, while 'RGB' uses three layers at a time for true color
% images.  An error is generated for 4+ dimensional arrays, and warnings
% are issued when this method is applied to column/row arrays. 
%
% See also TAF, plotColumns, plotRows, setROI
%
function image(object,scaled)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(scaled) || strcmpi(scaled,'scaled')
    scaled=true();
elseif strcmpi(scaled,'RGB')
    scaled=false();    
else
    error('ERROR: invalid image mode');
end

% create plot
fig=createFigure('Name','TAF image');
tg=uitabgroup(fig);
for n=1:numel(object)
    % verify file
    try
        info=object(n).Info;
    catch ME
        throwAsCaller(ME);
    end
    assert(any(info.Dimensions == [2 3]),...
        'ERROR: cannot image arrays with %d dimensions',...
        info.Dimensions);
    if any(info.TypeCode == 1)
        warning('TAF:TypeCode',...
            'This method is not meant for use with column arrays');
    elseif any(info.TypeCode == 2)
        warning('TAF:TypeCode',...
            'This method is not meant for use with row arrays');
    end
    % read and plot array
    grid=cell(1,info.Dimensions);
    try
        [data,grid{:}]=read(object(n));
    catch ME
        throwAsCaller(ME);
    end
    layers=size(data,3);
    if ~scaled
        assert(rem(layers,3) ==  0,...
            'ERROR: "%s" is cannot be shown as an RGB image',...
            object(n).Name);
    end
    t=uitab(tg,'Title',object(n).Name);
    GridLabel=generateGridLabel(object(n));
    k=1;
    SubCounter=0;
    while k <= layers
        if scaled
            temp=data(:,:,k);
        else
            temp=data(:,:,k:k+2);
            if isfloat(temp)
                temp=rescale(temp,0,1);
            end
        end
        if layers > 1
            if k == 1
                tgL=uitabgroup(t,'TabLocation','bottom');
            end
            SubCounter=SubCounter+1;
            parent=uitab(tgL,'Title',sprintf('Layer %d',SubCounter));
        else
            parent=t;
        end
        axes(parent,'Box','on');
        imagesc(grid{2},grid{1},temp);
        xlabel(GridLabel{2});
        ylabel(GridLabel{1});
        if scaled
            hc=colorbar();
            hc.Label.String='Data';
            k=k+1;
        else
            k=k+3;
        end
    end
end