% UNDER CONSTRUCTION
%
% See also kinterp2
%
function object=build(object,varargin)

% manage input
switch numel(varargin)
    case 0
        error('ERROR: insufficient input')
    case 1
        Z=varargin{1};
        [rows,cols]=size(Z);
        x=1:rows;
        y=1:cols;
    case 2
        error('ERROR: two coordinate grids required');
    case 3
        x=varargin{1};
        y=varargin{2};
        Z=varargin{3};  
    otherwise
        error('ERROR: too many inputs');
end

% error checking
assert(isnumeric(x) && isnumeric(y) && isnumeric(Z),...
    'ERROR: invalid grid/data input');
assert(ismatrix(Z),'ERROR: interpolation data must be a 2D array');
[rows,cols]=size(Z);
Nx=numel(x);
assert(Nx == rows,'ERROR: x grid inconsistent with interpolation data');
x=reshape(x,Nx,1);
Ny=numel(y);
assert(Ny == cols,'ERROR: y grid inconsistent with interpolation data');
y=reshape(y,1,Ny);


% sort data as needed
if x(end) < x(1)
    x=x(end:-1:1);
    Z=Z(end:-1:1,:);
end
assert(all(diff(x) > 0),'ERROR: x grid must be monotonic');

if y(end) < y(1)
    y=y(end:-1:1);
    Z=Z(:,end:-1:1);
end
assert(all(diff(y) > 0),'ERROR: y grid must be monotonic');

% create 1D interpolations for each grid line
for row=1:Nx
    new=SLAM.Sesame.kinterp1(y,Z(row,:));
    if row == 1
        object.InterpolateRow=repmat(new,Nx,1);
    else
        object.InterpolateRow(row)=new;
    end
end

for col=1:Ny
    new=SLAM.Sesame.kinterp1(x,Z(:,col));
    if row == 1
        object.InterpolateColumn=repmat(new,1,Ny);
    else
        object.InterpolateColumn(col)=new;
    end
end

end