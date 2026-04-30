% searchComments Search material comments
%
% This method searches the Sesame file for comments matching a specified
% pattern.  
%    material=searchComments(object,pattern);
% The input "pattern" (character array or scalar string) indicates the text
% to be searched for in a case-insensitive manner.  The output "material"
% lists the material model numbers containing the requested text pattern.
% 
% Multiple patterns:
%    material=searchComments(object,pattern1,pattern2,...);
% may be specified to restrict the search of material comments  with more
% than one criteria. 
%
% See also File, search, searchTables
%
function [material,index]=searchComments(object,varargin)

% manage input
Narg=numel(varargin);
assert(Narg > 0,'ERROR: text pattern(s) must be specified');
for k=1:Narg
    assert(ischar(varargin{k}) || isStringScalar(varargin{k}),...
        'ERROR: invalid search pattern');
end

% perform search
match=false(size(object.Data));
for m=1:numel(object.Data)
    record=object.Data(m);
    flag=false(1,Narg);
    for n=1:numel(record.Table)
        entry=record.Table(n);
        number=entry.Table;
        if (number < 101) || (number > 10199) ...
                || ((number > 199) && (number <10101))
            continue
        end
        for k=1:Narg
            if contains(entry.Data,varargin{k},'IgnoreCase',true)
                flag(k)=true;                
            end
        end       
    end
    if all(flag)
        match(m)=true;
    end
end

index=find(match);

list=object.Data(index);
material=nan(size(list));
for n=1:numel(list)
    material(n)=list(n).Material;
end
material=unique(material);

end