% replace Replace array data
%
% This method replaces array data with a specified value.
%    replace(object,value);
% Mandatory input "value" must be a real, numeric array that will overwrite
% the current ROI.  The array must either be a scalar or match the ROI
% size/shape.
%
% NOTE: this method only works for direct numeric storage.  Arrays stored
% as scaled integers (i.e. with finite slope) cannot be replaced, and
% calling this method with such files generates an error.
%
% See also TAF, setROI
%
function replace(object,new)


% manage input
assert(nargin() > 1,'ERROR: replacement value(s) must be specified');
assert(isnumeric(new) && isreal(new),'ERROR: ')

% manage object arrays
if ~isscalar(object)
    for n=1:numel(object)
        replace(object(n),new);
    end
    return
end

% verify comparability
try
    info=object.Info;
catch ME
    throwAsCaller(ME);
end

assert(isinf(info.Intercept) && isinf(info.Slope),...
    'ERROR: cannot replace scaled integer array');
old=read(object);
if isscalar(new)
    new=repmat(new,size(old));
else
    assert(all(size(new) == size(old)),...
        'ERROR: replacement array is not compatible with ROI');
end

map=object.MemoryMap;
map.Writable=true();
index=cell(1,info.Dimensions);
for k=1:info.Dimensions
    index{k}=object.ROI(k,1):object.ROI(k,2);
end
map.Data.Array(index{:})=new;

map.Writable=false();

end