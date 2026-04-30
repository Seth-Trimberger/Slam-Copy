% revise Modify existing record
%
% This method modifies an existing data record by name:
%    revise(object,name,value,row,column,...);
% or numeric index.
%    revise(object,index,value,row,column,...);
% Numeric "value" is written to the specified rows/columns; additional
% arguments are allowed for higher dimension records.  
%
% Data revision usually requires some knowledge of the existing array size.
% Row/column requests must be consistent with that size in MATLAB array
% assignments.  For example, suppose the existing array is 1xN and that
% "value" is a scalar.  The following commands:
%    revise(object,name,value,1,1);
%    revise(object,name,value,1,N);
%    revise(object,name,value,1,N+1);
% change the first/last element and append a new element, respectively.
%
% This capability is recommended for advanced users only.
%
% NOTE: only numeric records can be revised.  Revisions are only permitted
% when the Overwrite property is set to 'on'.
%
% See also ISPfile, find, write
%
function revise(object,arg,value,varargin)

assert(strcmp(object.Overwrite,'on'),...
    'ERROR: cannot revise record unless ''Overwrite'' property is ''on''');  

% manage input
Narg=nargin();
assert(Narg > 3,'ERROR: insufficient input');

try
    [record,name,index]=find(object,arg);
catch ME
    throwAsCaller(ME);
end

assert(isnumeric(value),'ERROR: revision is limited to numeric values');
report=probe(object);
valid={'double' 'single' 'int8' 'uint8' 'int16' 'uint16' ...
    'int32' 'uint32' 'int64' 'uint64'};
assert(any(strcmpi(report(index).Class,valid)),...
    'ERROR: revision is limited to numeric records')        

% attempt revision
try
    object.Matfile.(record)(varargin{:})=value;
catch ME
    throwAsCaller(ME);
end
h5writeatt(object.File,['/' record],'Name',name);

end