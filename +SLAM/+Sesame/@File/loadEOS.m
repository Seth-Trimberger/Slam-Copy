% loadEOS Load equation of state
%
% This method loads equation of state data for a specified material.
%    model=loadEOS(object,material);
% Mandatory input "material" indicates the integer material number read
% from the Sesame file.
%
% NOTE: this method only works for materials having both a 201 and 301
% table.   
%
% See also File, EOS
%
function out=loadEOS(object,material)

% manage input
assert((nargin() > 1) && ~isempty(material),...
    'ERROR: material number must be specified');
try
    [~,data]=query(object,material);
catch
    error('ERROR: requested material not found');
end

% make sure EOS tables are present
k=nan(1,2);
for n=1:numel(data.Table)
    if data.Table(n).Table == 301
        k(1)=n;
    elseif data.Table(n).Table == 201
        k(2)=n;
    end
    if all(isfinite(k))
        break
    end
end
assert(isfinite(k(1)),...
    'ERROR: 301 table not available for material %d',material)
raw=data.Table(k(1)).Data;

if isfinite(k(2))
    rho0=data.Table(k(2)).Data(3);
else
    rho0=[];
end

out=SLAM.Sesame.EOS(raw,rho0);
out.Name=sprintf('%d',material);

end