% extend Extend array along its last dimension
%
% This method extends the stored array along its last dimension.
%    extend(object,data);
% Mandatory input "data" indicates the numeric values to be added along the
% last dimension (e.g. extending a 2D array adds columns).  Scalar
% data is automatically replicated for consistency with the existing array
% (incremented the last dimension size by one).  In all other cases, the
% size of "data" must be consistent with all array dimensions before the
% final one.  For example, extending a 2D array requires "data" to have the
% same number of rows as the stored array.
%
% NOTE: files with comments and scaled integer arrays cannot be extended.
% Attempting to do either generates an error.
%
% See also TAF, setComment, transpose
%
function extend(object,data)

% manage input
Narg=nargin();
assert(Narg > 1,'ERROR: no data specified');
assert(isnumeric(data) && isreal(data),'ERROR: invalid data')

% manage object arrays
if ~isscalar(object)
    for n=1:numel(object)
        extend(object(n),data);
    end
    return
end

% verify compatibility
try
    info=object.Info;
catch ME
    throwAsCaller(ME);
end

assert(isinf(info.Intercept) && isinf(info.Slope),...
    'ERROR: cannot extend scaled integer array');
assert(isempty(info.Comments),...
    'ERROR: cannot extend file while comments are present');

L1=info.Size;
if isscalar(data)
    L2=L1;
    L2(end)=1;
    data=repmat(data,L2);
else
    ND=ndims(data);
    valid=info.Dimensions+[-1 0];
    assert(any(ND == valid),...
        'ERROR: cannot extend %dD array with %dD data',...
        info.Dimensions,ND)
    L2=size(data);

    for k=1:(info.Dimensions-1)
        assert(L1(k) == L2(k),'ERROR: incompatible array size detected');
    end       
end

% update file 
data=cast(data,info.Format);

fid=fopen(object.Target,'r+','ieee-le');
fseek(fid,info.DataOffset,'bof');
fseek(fid,-3*8,'cof'); % update last dimension size
temp=size(data);
fwrite(fid,info.Size(end)+temp(end),'uint64');

fseek(fid,info.CommentOffset,'bof');
fwrite(fid,data,info.Format);
fclose(fid);

object.PreviousInfo=[];
setROI(object);

end