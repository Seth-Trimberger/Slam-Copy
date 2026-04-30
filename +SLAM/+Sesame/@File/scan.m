% scan Read Sesame ASCII2 file
%
% This method reads a Sesame ASCII2 file based on specifciations from
% report LA-UR-19-24891.  This information is automatically stored in the
% Data property:
%    scan(object);
% or may be returned as a structure (without updating Data).
%    report=scan(object);
%
% See also File
%
function varargout=scan(object)

fid=fopen(fullfile(object.Location,object.Name));
CU=onCleanup(@() fclose(fid));
[~]=fgetl(fid);

report=[];
while ~feof(fid)
    new=readTable(fid);
    temp=struct('Material',new.Material,'Table',new);
    if new.File == 0        
        if isempty(report)
            report=temp;
        else
            report(end+1)=temp; %#ok<AGROW>
        end
    else
        report(end).Table(end+1)=new;
    end
end

% manage output
if nargout() > 0
    varargout{1}=report;
else
    object.Data=report;
end

end

%%
function out=readTable(fid)

out.Start=ftell(fid);
header=fgetl(fid);
value=sscanf(header,'%u');

assert(numel(value) == 7,'ERROR: invalid table definition');

out.File=value(1);
assert(any(out.File == [0 1]),'ERROR: invalid file number');
out.Material=value(2);
out.Table=value(3);
if out.File == 0
    assert(out.Table == 101,'ERROR: invalid material definition');
end
out.Words=value(4);
out.Created=value(5);
out.Updated=value(6);
out.Version=value(7);

out.IsComment=false;
if ((out.Table >= 101) && (out.Table <= 199)) ...
        || ((out.Table >= 10101) && (out.Table <= 10199)) % comment table
    out.IsComment=true;
    out.Data='';
    while numel(out.Data) < out.Words
        buffer=fgetl(fid);
        out.Data=[out.Data buffer];
    end
    out.Data=regexprep(out.Data,'\s+',' ');
else % data table
    out.Data=fscanf(fid,'%g',[1 out.Words]);
    [~]=fgets(fid); % go to next line
end
out.Stop=ftell(fid)-1;

end