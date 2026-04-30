% setROI Define region of interest
%
% This method defines the region of interest used by other methods, such as
% plot and read.  The ROI is constructed from restrictive combination of
% two bound types.
%    setROI(object,index,grid);
% Optional inputs "index" and "grid" define the region of interest using
% two-column array bounds.
%    -Index bounds define elements directly, e.g. [1 10] indicates the
%    first through the tenth element.  These bounds *must* be integers that
%    reference from the left (1 to L) or right (-L+1 to 0) side of a
%    dimension with L elements; the latter are automatically incremented by
%    L.  Index values below 1 or greater than L are replaced by 1 or L,
%    respectively.
%    -Grid bounds reference the implicit grid, e.g. [0 1] indicates
%    elements where the implicit grid is >= 0 and <= 1.  Non-integer and
%    infinite values are permitted.
% Each row of "index" and "grid" define bounds for one array dimension.
% Omitted rows imply the full range of higher dimensions, e.g.:
%     setROI(object,[m1 m2]);
% limits the first to dimension to elements m1:m2 while all elements are
% included for the second dimension.  Empty/omitted arrays also indicate
% inclusion of the full range.
%    setROI(object); % use all elements in ROI.
%    setROI(object,index); % index bounds only
%    setROI(object,[],grid); % grid bounds only
%
% See also TAF, crop, image, read, plotColumns, plotRows
%
function setROI(object,varargin)

if ~isscalar(object)
    for n=1:numel(object)
        setROI(object(n),varargin{:});
    end
    return
end

info=object.Info;

% manage input
index=repmat([1 inf()],[info.Dimensions 1]);
grid=repmat([-inf inf],[info.Dimensions 1]);

Narg=numel(varargin);
assert(any(Narg == [0 1 2]),'ERROR: invalid number of inputs')
    function bound=parseBound(request,default)       
        [rows,cols]=size(request);
        assert(isnumeric(request) && ismatrix(request) && (cols == 2),...
            'ERROR: invalid bound array');
        bound=default;
        for mm=1:rows
            if mm > info.Size(mm)
                warning('TAF:ExtraBounds','Ignoring extra ROI bounds');
                break
            end
            bound(mm,:)=request(mm,:);
        end
    end

if Narg > 0  
    if isempty(varargin{1})
        varargin{1}=index;
    end
    try
        index=parseBound(varargin{1},index);
    catch ME
        throwAsCaller(ME);
    end
end

if Narg > 1
    try
        grid=parseBound(varargin{2},grid);
    catch ME
        throwAsCaller(ME);
    end
end

% verify index/grid requests
flag=(index == round(index));
assert(all(flag(:)),'ERROR: non-integer index requested');
for m=1:info.Dimensions    
    k=(index(m,:) < 1);
    index(m,k)=index(m,k)+info.Size(m);
    index(m,1)=max(index(m,1),1);
    index(m,2)=min(index(m,2),info.Size(m));
end

for m=1:info.Dimensions
    xb=sort(grid(m,:));
    nb=round((xb-info.Start(m))/info.Step(m)+1);
    index(m,1)=max(index(m,1),nb(1));
    index(m,2)=min(index(m,2),nb(2));
end

% store new ROI
assert(all(index(:,2) >= index(:,1)),...
    'ERROR: requested ROI contains no data')

object.ROI=index;

end