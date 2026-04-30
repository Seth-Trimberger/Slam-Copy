% lookupMaterial Find parameters by material name
%
% This *static* method looks up material parameters by name.  This
% information can be printed in the command window:
%    Impact.lookupMaterial(name);
% or returned as output argumements.
%    [rho0,param]=Impact.lookupMaterial(name); % param = [c0 s]
% Optional input "name" indicates the material in case-insensitive manner.
% Omitting the input:
%    Impact.lookupMaterial();
% prints a liste of valid material names in the command window.
%
% See also Impact
%
function varargout=lookupMaterial(name)

persistent data
if isempty(data)
    data=cell(0,2);
    location=fileparts(mfilename('fullpath'));    
    file=fullfile(location,'materials.txt');
    fid=fopen(file,'r');
    CU=onCleanup(@() fclose(fid));   
    while ~feof(fid)
        buffer=strtrim(fgetl(fid));
        if buffer(1) == '$'
            continue
        end
        try
            material=strtrim(extractBefore(buffer,','));
            remain=extractAfter(buffer,',');
            remain=strrep(remain,',',' ');
            value=sscanf(remain,'%g',3);
            assert(numel(value) == 3,'');            
        catch
            continue
        end
        data{end+1,1}=material; %#ok<AGROW>
        data{end,2}=value;
    end
end

% manage input
Narg=nargin();
if Narg == 0
    assert(nargout() == 0,'ERROR: no outputs returned in query mode');
    fprintf('Materials available:\n');
    temp=data(:,1);
    fprintf('\t%s\n',temp{:});
    return
end

assert(ischar(name) || isStringScalar(name),...
    'ERROR: invalid material name');
success=false;
for n=1:size(data,1)
    if strcmpi(name,data{n,1})
        success=true;
        break
    end
end
assert(success,'ERROR: no material data found for "%s"',name);

param=data{n,2};
density0=param(1);
param=param(2:end);

% manage output
if nargout() > 0
    varargout{1}=density0;
    varargout{2}=param;
    return
end
fprintf('Material properties for %s\n',name);
fprintf('\trho0 = %g g/cc\n',density0);
fprintf('\tc0   = %g km/s\n',param(1));
fprintf('\ts    = %g \n',param(2));

end