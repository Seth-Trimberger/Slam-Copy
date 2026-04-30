% probe Query file content
%
% This method probes ISP file content, revealing the name, class, and size
% of all stored variables.  This information can be returned as a structure
% array:
%    report=probe(object);
% or printed in the command window.
%    probe(object).
%
% See also ISPfile, read
%
function varargout=probe(object)

% probe entire file
list=whos(object.Matfile);
report=struct('Name','var','Dataset','record','Size',[1 1],...
    'Class','double','Bytes',0);
report=repmat(report,size(list));
keep=false(size(list));
for n=1:numel(list)
    k=sscanf(list(n).name,'record%d',1);
    if isempty(k)
        continue
    end
    keep(n)=true();
    report(n).Dataset=['/' list(n).name];
    report(n).Name=h5readatt(object.File,report(n).Dataset,'Name');
    report(n).Class=list(n).class;
    report(n).Size=list(n).size;
    report(n).Bytes=list(n).bytes;   
end
report=report(keep);

% manage output
if nargout() > 0
    varargout{1}=report;   
elseif isempty(report)
    fprintf('No stored records\n');
else
    fprintf('Stored records\n');
    for n=1:numel(report)
        buffer=sprintf('%dx',report(n).Size);
        buffer=buffer(1:end-1);
        fprintf('   %d: "%s" (%s %s)\n',n,report(n).Name,buffer,report(n).Class);
    end
end

end