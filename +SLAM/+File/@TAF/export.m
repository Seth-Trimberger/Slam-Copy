% export Write array data to text file
%
% This method exports a stored array to a text file.
%    export(object,format);
% Optional input "format" indicates how numeric data is written.  The
% default value is '%s', and any valid format specification for sscanf can
% be used (e.g, '%#+.6g').  Although multiple files can be exported
% simultaneously (when "object" is an array), each must contain a
% two-dimensional array; an error is generated when higher dimensionality
% is present. Only data from the current ROI is read from the source file
% and written to the export file.
% 
% Export files are named after the source file, appending the text
% '_export' and using the '.txt' extension.  Requesting an output:
%    file=export(object,format);
% returns a string array of export files.  Each file begins with a time
% stamp followed by a text header describing array size and grid start/stop
% values. Pure numeric lines are reserved for the array itself, followed by
% any text comments from the source.
%
% See also TAF, read, setROI
%
function varargout=export(object,format)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(format)
    format='%g';
else
    try
        [~]=sprintf(format,1);
    catch
        error('ERROR: invalid format specification');
    end
end

% print array data as text
N=numel(object);
file=cell(1,N);
for n=1:N
    try
        info=object(n).Info;
    catch ME
        throwAsCaller(ME);
    end
    assert(info.Dimensions == 2,...
        'ERROR: cannot export %dD array to a text file',info.Dimensions);
    [~,base,~]=fileparts(object(n).Name);
    stamp=handy.timestamp('unique');
    file{n}=[base '_export.txt'];
    fid=fopen(file{n},'w');
    fprintf(fid,'%s file exported %s\n',object(n).Name,stamp);
    temp=sprintf('Rows: %s\\n',format);    
    fprintf(fid,temp,info.Size(1));
    temp=sprintf('Columns: %s\\n',format);    
    fprintf(fid,temp,info.Size(2));
    for k=1:info.Dimensions
        temp=sprintf('Grid %d start: %s\\n',k,format);
        fprintf(fid,temp,info.Start(k));
        temp=sprintf('Grid %d step: %s\\n',k,format);
        fprintf(fid,temp,info.Step(k));
    end
    data=read(object(n));
    temp=repmat([format ' '],1,info.Size(2));
    temp=[temp(1:end-1) '\n'];
    fprintf(fid,temp,transpose(data));
    fprintf(fid,'%s',info.Comments);
    fclose(fid);
end

% manage output
if nargout() > 0
    varargout{1}=string(file);
end

end