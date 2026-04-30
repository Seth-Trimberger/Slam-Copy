% read Read data from file
%
% This method reads data from the ISP file.
%    value=read(object,name);
% The output "value" returns the data stored on the requested "name"
% (character array or scalar string).  Omitting this input:
%    value=read(object);
% returns the most recently written data.  Passing a numeric index:
%    value=read(object,k);
% requests data in the order it was saved.  For a file with N stored
% records, "k" can be any integer from -N+1 to N, where values below 1
% are internally incremented by N (e.g., 0 indicates the last record, -1
% the one before that, and so forth).
%
% NOTE: attempting to read an empty file generates an error.
%
% See also ISPfile, write
%
function [value,name]=read(object,arg,varargin)

if nargin() < 2
    arg=[];
end
try
    [record,name]=find(object,arg);
catch ME
    throwAsCaller(ME);
end

% determine if class is available
info=probe(object);


% look up requested record
if isempty(varargin)
    value=object.Matfile.(record);
else
    value=object.Matfile.(record)(varargin{:});
end

end