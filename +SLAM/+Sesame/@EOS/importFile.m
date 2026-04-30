% importFile Import data from Sesame file
%
% This *static* method imports data from a Sesame file (Los Alamos ASCII
% format, version 2).  Information is loaded from the file by number:
%    object=EOS.importFile(file,material);
% where the input "material" is optional for files containing a single
% material.  Multiple models can also be loaded simultaneously:
%    object=EOS.importFile(file,material1,material2,...);
% where the output "object" has one element per requested material.
%
% See also EOS
%
function object=importFile(file,varargin)

% manage input
Narg=nargin();
assert(Narg > 0,'ERROR: insufficient input');
try
    source=SLAM.Sesame.File(file);
catch ME
    throwAsCaller(ME);
end
valid=source.Materials;

if Narg < 2
    assert(isscalar(valid),'ERROR: material number must be specified');
    varargin{1}=valid;
end

for n=1:numel(varargin)
    try
        new=loadEOS(source,varargin{n});
    catch ME
        throwAsCaller(ME);
    end 
    if n == 1
        object=repmat(new,size(varargin));
    else
        object(n)=new;
    end
end

end