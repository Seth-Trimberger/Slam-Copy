% find Find record based on name or numeric index
%
% This method finds the record associated with a specified name:
%    record=find(object,name); % "name" is a character array or scalar string
% or numeric index:
%    record=find(object,index); % "index" is an integer
% For a file containing N records, valid index values are 1 to N and
% -N+1:0, where values below 1 are automatically incremented by N.  This
% means than 0 represents the last record, -1 the record before that, and
% so on.  The last record is referenced by default.
%    record=find(object);
%
% The output "record" is a character array starting with 'record' followed
% by an integer.  For example, the first record is always 'record1', which
% corresponds to the HDF5 dataset '/record1'.  Additional output requests:
%    [record,name,index]=find(object,...);
% return the name and numeric index of the matching record.
%
% See also ISPfile
%
function [record,name,index]=find(object,arg)

report=probe(object);
if isempty(report)
    warning('ISP:EmptyRepack','File is empty \n');
    return
end
if (nargin() < 2) || isempty(arg)
    index=numel(report);
elseif isnumeric(arg)
    index=arg;
    if index < 1
        index=index+numel(report);
    end
    try
        [~]=report(index);
    catch
        error('ERROR: invalid record index');
    end
else
    success=false();
    for n=1:numel(report)
        if strcmp(report(n).Name,arg)
            index=n;
            success=true();
            break
        end
    end
    assert(success,'ERROR: record name not found');
end

record=report(index).Dataset(2:end);
name=report(index).Name;

end