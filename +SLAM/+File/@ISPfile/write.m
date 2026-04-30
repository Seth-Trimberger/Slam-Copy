% write Write data to file
%
% This method writes data to the ISP file.
%    write(object,value,name);
% Mandatory input "value" indicates the data to be written, which can be
% any variable the current workspace.  Optional input "name" defines the
% text name associated with the stored record.  A basic name, e.g. 'data1',
% is generated when this input is empty/omitted.
%
% NOTE: when the requested name is already present in the file, that data
% will be overwritten *if* the Overwrite property is set to 'on'.  The
% default value is 'off', i.e. existing data is write protected unless the
% property is changed.
%
% See also ISPfile, pack, read
%
function write(object,value,name)

% manage input
Narg=nargin();
assert(Narg > 1,'ERROR: data must be specified');

persistent counter
if isempty(counter)
    counter=1;
end

if (Narg < 3) || isempty(name)
    name=sprintf('data%d',counter);
    counter=counter+1;
else
    if isStringScalar(name)
        name=char(name);
    end
    assert(ischar(name),'ERROR: invalid name');
end

% warn user about writing objects
if isobject(value)
    msg{1}='Stored objects may be inaccessible without the class definition.';
    msg{2}='Consider using structures for greater portability';
    warning('ISPfile:objects','%s\n',msg{:});
end

% replace existing record
report=probe(object);
N=numel(report);
for n=1:N
    if strcmp(report(n).Name,name)
        assert(strcmp(object.Overwrite,'on'),...
            'ERROR: cannot update record unless ''Overwrite'' property is ''on''');         
        record=report(n).Dataset;
        object.Matfile.(record(2:end))=value;
        h5writeatt(object.File,record,'Name',name);
        return
    end
end

% create new record
record=sprintf('record%d',N+1);
dummy.(record)=value;
save(object.File,'-mat','-append','-struct','dummy');
h5writeatt(object.File,['/' record],'Name',name);

end