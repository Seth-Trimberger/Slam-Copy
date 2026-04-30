% write Generate a Thrifty Array Format file
%
% This function creates a Thrifty Array Format (*.taf) file using specified
% data array.
%    writeTAF(data,file);
% Mandatory input "data" must be a numeric array.  Optional input "file"
% indicates where the this data will be written, prompting the user to
% select a file when this information is empty or omitted.  
%
% Grid arrays can be passed as additional input arguments.
%    writeTAF(data,file,grid1,grid2,...);
%
% NOTE: this function only provides a subset of TAF capabilities.
%
% See also SLAM.File, TAF, readTAF
%
function writeTAF(data,file,varargin)

% manage input
Narg=nargin();
assert(Narg > 0,'ERROR: data array must be specified');

if Narg < 2
    file=[];
end

%
try
    SLAM.File.TAF.create(data,file,[],varargin{:});
catch ME
    throwAsCaller(ME);
end

end