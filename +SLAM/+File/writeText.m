% writeText Write numeric data to a text file
%
% This function writes numeric data to a text file.
%    writeText(data,file,format,header,mode);
% The input "data" is the two-dimensional numeric array that will be
% written.  Optional input "file" indicates the file where this data will
% be written, prompting the user when omitted or empty.  Calling the
% function with no input:
%    writeText();
% generates an example file called 'writeTextDemo.txt' that illustrates
% various write features.
%
% Optional input "format" controls how the columns of "data" are written.
% The default state uses '%+#g' for every column. Manual format
% specifications are permitted as long as there is one % character
% (replicated for each column) *or* one % character per column.  Numeric
% values are interpreted as the number of significant digits as illustrated
% below.
%    -The value 5 is converted to '%+#.5g'.
%    -The value [3 5] is converted to '%+#.3g %+#.5g'.
% Signs and trailing characters (zeros and decimal points) are always used
% unless "format" is explicitly specified otherwise.  See the sprintf
% function for more details.
%
% Optional input "header" allows a text header to been written above the
% numeric array.  This input is empty by default.  Character values are
% converted to a cellstr array, and cellstr/string arrays can be used for
% multi-line text.
%
% Optional input "mode" controls how data is written when the requested
% file already exists.  Existing files are overwritten by default and when
% "mode" is set to 'write'.  Requesting 'append' mode adds the text header
% and data after an previous content.
%
% See also SLAM.File, readText, sprintf
%
function writeText(data,file,format,header,mode)

% manage input
Narg=nargin();
if Narg == 0
    fprintf('Writing demonstration file\n');
    t=0:(1/100):1;
    t=t(:);
    data=[t t.^2];
    file='writeTextDemo.txt';
    format=4;
    header{1}=sprintf('Example text file created %s',datetime('now'));
    header{end+1}=sprintf('Each column written with %d digits',format);
    header{end+1}='Second column is the square of the first column';
    Narg=4;    
end

assert(isnumeric(data) && ismatrix(data) && isreal(data) && ~isempty(data),...
    'ERROR: data must be a non-empty, real 2D numeric array');

if (Narg < 2) || isempty(file)
    [name,location]=uiputfile({'*.*' 'All files'},'Select text file');
    if isnumeric(name)
        fprintf('Text write cancelled\n');
        return
    end
    file=fullfile(location,name);
else
    try
        new=handy.portableFilename(file);
    catch ME
        throwAsCaller(ME);
    end
    if ~strcmp(new,file)
        fprintf('File name changed to "%s" for portability\n',new);
        file=new;
    end
end

columns=size(data,2);
if (Narg < 3) || isempty(format)
    format='%+#g';
elseif isnumeric(format)    
    digits=ceil(format);
    format=sprintf('%%+#.%dg ',digits);    
elseif isStringScalar(format)
    format=char(format);
else
    assert(ischar(format),'ERROR: invalid write format');
end
index=strfind(format,'%');
assert(~isempty(index),'ERROR: invalid write format');
if isscalar(index)
    temp=format(end);
    if ~isempty(sscanf(temp,'%s',1))
        format(end+1)=' ';
    end
    format=repmat(format,[1 columns]);
else
    assert(numel(index) == columns,...
        'ERROR: format request not compatible with data columns');
end
format=strip(format,'right');
if ~endsWith(format,'\n')
    format=[format '\n'];
end

if (Narg < 4) || isempty(header)
    header={};
else
    if ischar(header)
        header={header};
    end
    assert(iscellstr(header) || isstring(header),'ERROR: invalid header');
end

if (Narg < 5) || isempty(mode) || strcmpi(mode,'write')
    mode='write';
elseif strcmpi(mode,'append')
    mode='append';
else
    error('ERROR: invalid write mode');
end


% write data to file
switch mode
    case 'write'
        fid=fopen(file,'w');
    case 'append'
        fid=fopen(file,'a');
end

if ~isempty(header)
    fprintf(fid,'%s\n',header{:});
end

fprintf(fid,format,transpose(data));

fclose(fid);

end