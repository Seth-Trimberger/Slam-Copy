% search Search SESAME file
%
% This method searches the SESAME file for matching text comments.
%    material=search(object,pattern);
% Mandatory input "pattern" defines the search text used to find matches
% listed in output "material".  Patterns can be specified as a character
% array, cell array of characters, or string array.  For example:
%    material=search(object,{'copper' 'liquid'});
% returns only materials where both 'copper' and 'liquid' are mentioned in
% the comments.
%
% Searches can be further restricted to materials having a specified table
% number.
%    material=search(object,pattern,table);
% Option input "table" can be an integer or integer array.  For example:
%    material=search(object,'iron',301);
% limits results to iron materials having a complete EOS table.
%
% See also File, export, query
%
function material=search(object,comments,tables)

% manage input
Narg=nargin();
assert(Narg > 1,'ERROR: text pattern must be specified');

if (Narg < 3) || isempty(tables)
    tables={};
elseif isnumeric(tables)
    tables=num2cell(tables);
else
    assert(isnumeric(tables),'ERROR: invalid table request');
end

if ischar(comments)
    comments={comments};
else
    assert(isstring(comments) || iscellstr(comments),...
        'ERROR: invalid text pattern');
end

% perform searches
try
    A=searchComments(object,comments{:});
catch ME
    throwAsCaller(ME);
end

if isempty(tables)
    material=A;
else
    try        
        B=searchTables(object,tables{:});
    catch ME
        throwAsCaller(ME);
    end
    material=[];
    for m=1:numel(A)
        for n=1:numel(B)
            if A(m) == B(n)
                material(end+1)=A(m); %#ok<AGROW>
            end
        end
    end
end

end