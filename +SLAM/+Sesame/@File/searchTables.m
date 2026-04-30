% searchTables Search material tables
%
% This method searches the Sesame file for materials have a specified
% table.
%    material=searchTables(object,table1,table2,...);
% The output "material" is an integer list of materials having *all*
% specified tables.
%
% See also File, search
%
function [material,index]=searchTables(object,varargin)

% manage input
Narg=numel(varargin);
assert(Narg > 0,'ERROR: table number(s) must be specified');
for k=1:Narg
    value=varargin{k};
    assert(isnumeric(value) && isscalar(value),...
        'ERROR: invalid table number');
end

% perform search
match=false(size(object.Data));
for m=1:numel(object.Data)
    record=object.Data(m);
    flag=false(1,Narg);
    for n=1:numel(record.Table)
        entry=record.Table(n);
        number=entry.Table;
        for k=1:Narg
            if number == varargin{k}
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