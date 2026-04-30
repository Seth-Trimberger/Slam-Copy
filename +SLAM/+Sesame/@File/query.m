% query Query material comments and tables.
% 
% This method queries the comments and tables for a specfied material.
% Information can be printed in the command window:
%    query(object,material);
% or returned as a structure.
%    info=query(object,material);
% In both cases, mandatory input "material" must be a material number used
% in the Sesame file.
%
% See also File, export, search
%
function varargout=query(object,material)

% manage input
Narg=nargin();
valid=object.Materials;
assert((Narg > 1) && isscalar(material) && ...
    isnumeric(material),'ERROR: invalid material number');

% gather material information
k=find(material == valid);
assert(~isempty(k),'ERROR: material %d not found',material);
data=object.Data(k);
M=numel(data.Table);
out.Comment='';
out.Table=nan(1,M);
for m=1:M
    out.Table(m)=data.Table(m).Table;
    if ~data.Table(m).IsComment
        continue
    end
    out.Comment=sprintf('%s\n%s',out.Comment,data.Table(m).Data);
end
out.Comment=out.Comment(2:end);

% manage output
if nargout() > 0
    varargout{1}=out;
    varargout{2}=data;
    return
end
fprintf('Material %d has the following tables\n   ',material);
fprintf('%d ',out.Table);
fprintf('\n');
fprintf('Table comments:\n');
fprintf('%s',out.Comment);
fprintf('\n');

end