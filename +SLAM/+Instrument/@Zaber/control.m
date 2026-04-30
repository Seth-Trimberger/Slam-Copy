function control(object)

db=uifigure('Name','Zaber control');

main=uigridlayout(db);
main.ColumnWidth={'fit'};
main.RowHeight={'fit' 'fit' 'fit' 'fit'};
main.RowSpacing=5;

sub=uigridlayout(main,'ColumnWidth',{'fit' 'fit'},'RowHeight',{'fit'});
label=sprintf('SN: %s',object.SerialNumber);
uilabel(sub,'Text',label,'FontWeight','bold');
label=sprintf('ID: %s',object.ID);
uilabel(sub,'Text',label,'FontWeight','bold');

sub=uigridlayout(main);
sub.ColumnWidth={'fit' 'fit'};
sub.RowHeight={'fit' 'fit'};
sub.RowSpacing=1;
uilabel(sub,'Text','Current position:');
hCurrent=uieditfield(sub);
hCurrent.Layout.Row=2;
hCurrent.Layout.Column=1;
hRefresh=uibutton(sub,'Text','Refresh');

sub=uigridlayout(main);
sub.ColumnWidth={'fit' 'fit' 'fit'};
sub.RowHeight={'fit' 'fit' 'fit'};
sub.RowSpacing=1;
uilabel(sub,'Text','Shift increment:');
hIncrement=uieditfield(sub);
hIncrement.Layout.Row=2;
hIncrement.Layout.Column=1;
hForward=uibutton(sub,'Text','Forward');
hBackward=uibutton(sub,'Text','Backward');
hKeys=uicheckbox(sub,'Text','Use arrow keys');

sub=uigridlayout(main);
sub.ColumnWidth={'2x' 'fit'};
sub.RowHeight={'fit' 'fit' 'fit' 'fit' 'fit'};
uilabel(sub,'Text','Locations:');
hPosition=uilistbox(sub);
hPosition.Layout.Row=[2 5];
hPosition.Layout.Column=1;
hAdd=uibutton(sub,'Text','Add');
hAdd.Layout.Row=2;
hAdd.Layout.Column=2;
hRename=uibutton(sub,'Text','Rename');
hRename.Layout.Row=3;
hRename.Layout.Column=2;
hRename=uibutton(sub,'Text','Delete');
hRename.Layout.Row=4;
hRename.Layout.Column=2;

pause(0.5);

L=findBounds(findall(db));
margin=10;
db.Position(3)=L(1)+2*margin;
db.Position(4)=L(2)+2*margin;

end

function L=findBounds(child)

left=inf;
right=-inf;
bottom=+inf;
top=-inf;
for n=1:numel(child)
    if any(strcmpi(child(n).Type,{'figure','GridLayout'}))
        continue
    end
    pos=getpixelposition(child(n));
    left=min(left,pos(1));
    right=max(right,pos(1)+pos(3));
    bottom=min(bottom,pos(2));
    top=max(top,pos(2)+pos(4));
end
L=[right-left top-bottom];

end