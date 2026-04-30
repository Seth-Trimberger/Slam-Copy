% read Read array and grid data
%
% This method reads array data from the file.
%    [data,grid1,grid2,...]=read(object);
% The output "data" contains array elements from the current ROI.  Each
% subsequent output are the corresponding grid vectors from that ROI.
%
% See also TAF, plot, setROI
%
% NOTE: files must be read one at a time--object arrays are not permitted
%
function [data,varargout]=read(object)

assert(isscalar(object),'ERROR: files must be read one at a time');

% verify file
try
    info=object.Info;
catch ME
    throwAsCaller(ME);
end

% read requested data
index=cell(1,info.Dimensions);
for m=1:info.Dimensions
    index{m}=object.ROI(m,1):object.ROI(m,2);
end
map=object.MemoryMap;
data=map.Data.Array(index{:});

if isinf(info.Slope) || any(strcmpi(info.Format,{'double' 'single'}))
    % do nothing
elseif info.Slope == 0
    data=repmat(info.Intercept,size(data));
else
    data=double(data);
    data=info.Intercept+info.Slope*data;
end

% manage output
Nout=nargout()-1;
varargout=cell(1,Nout);
for n=1:Nout
    varargout{n}=info.Start(n)+(index{n}-1)*info.Step(n);
end

end