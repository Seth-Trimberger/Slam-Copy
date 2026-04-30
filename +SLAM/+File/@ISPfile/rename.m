% rename Rename record
%
% This method renames an existing record by name:
%    rename(object,old,new); % "old" is a character array or scalar string
% or by index:
%    rename(object,index,new); % "index" is an integer
% defaulting to the last record when "index" is empty.  The input "new"
% must be a character array or scalar string that will replace the current
% name.
% 
% See also ISPfile, find
%
function rename(object,arg,new)

% manage input
Narg=nargin();
assert(Narg == 3,'ERROR: invalid number of inputs');

if isStringScalar(new)
    new=char(new);
end
assert(ischar(new),'ERROR: invalid name');

% attempt rename
try
    record=find(object,arg);
catch ME
    throwAsCaller(ME);
end

h5writeatt(object.File,['/' record],'Name',new);

end