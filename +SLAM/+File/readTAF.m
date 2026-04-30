% readTAF Read Thrifty Array Format file
%
% This function reads the data array and implicit grids from a Thrifty
% Array Format (*.taf) file.
%    [data,grid1,grid2,...]=readTAF(file);
% Optional input "file" indicates the file to be read, prompting the user
% when missing or omitted.  Output "data" returns the stored array,
% followed as "grid" arrays as requested.  Every TAF file has
% at least two implicit grids, and additional grids may be present when for
% arrays with more than two dimensions.  A warning is generated when more
% grids are requested than stored in the file
%
% NOTE: this function only provides a subset of TAF capabilities.
%
% See also SLAM.File, TAF
%
function [data,varargout]=readTAF(varargin)

try
    object=SLAM.File.TAF(varargin{:});   
catch ME
    throwAsCaller(ME);
end

NR=nargout()-1;
N=object.Info.Dimensions;
varargout=cell(1,N); 
try
    [data,varargout{:}]=read(object);
catch ME
    throwAsCaller(ME);
end

if NR > N
    varargout{NR}=[];
    warning('Empty values returned for grid requests beyond %d',N);
end

end