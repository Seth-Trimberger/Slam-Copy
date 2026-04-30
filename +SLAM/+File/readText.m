% readText Read numeric data from a text file
%
% This function reads numeric data from a text file.  Data blocks are
% identified by lines containing only numbers, white space, and/or standard
% delimiters (',' and '&'); the number of data columns is determined
% automatically.  All other lines are treated as part of a text header.
% The command:
%    [data,header]=readText(file);
% returns numeric array "data" and cellstr "header, the latter capturing
% all file text before the array.  Users are prompted to select a file if
% the input "file" is empty or omitted.
%
% Numeric data is read until the file ends, the numeric format changes
% (number of columns/delimiters changes), or more text is found.  Adding a
% second input:
%    [data,header]=readText(file,'repeat');
% allows header/data/ blocks to be repeatedly read until the file end is
% reached.  The default state is:
%    [data,header]=readText(file,'norepeat');
% An important difference between standard and repeated reads is that the
% outputs are cell arrays.
%     -"data" is a cell array of numeric arrays, each of which may of
%     different size.
%     -"header" becomes a cell array of cellstr values.  
% The number of elements in each output is for repeated reads, i.e. there
% is always one header for each numeric data block.
%
% See also SLAM.File, writeText
%
function [data,header]=readText(file,repeat)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(file)
    [name,location]=uigetfile({'*.*' 'All files'},'Select text file');
    if isnumeric(name)
        data=[];
        warning('File selection cancelled');
        return        
    end
    file=fullfile(location,name);
else
    assert(isfile(file),'ERROR: invalid file');
end

if (Narg < 2) || isempty(repeat) || strcmpi(repeat,'norepeat')
    repeat=false();
elseif strcmpi(repeat,'repeat')
    repeat=true();
else
    error('ERROR: invalid repeat state');
end

% 
fid=fopen(file,'r');
CU=onCleanup(@() fclose(fid));

data={[]};
header={};
local={};
counter=1;
while ~feof(fid)
    start=ftell(fid);
    buffer=strtrim(fgetl(fid));    
    local{end+1}=buffer; %#ok<AGROW>
    if isempty(buffer)
        continue
    end
    format='';
    column=0;
    success=true();
    while ~isempty(buffer)
        buffer=strtrim(buffer);
        if strcmp(buffer,'\\')
            format=[format '%*2s']; %#ok<AGROW>
            break
        end
        [~,n,~,next]=sscanf(buffer,'%g',1);
        if n > 0
            format=sprintf('%s%%g',format);
            buffer=buffer(next:end);
            column=column+1;
            continue
        elseif any(strcmp(buffer(1),{',' '&'}))
            format=sprintf('%s%%*1s',format);
            buffer=buffer(2:end);
            continue
        else
            success=false();           
            break
        end
    end
    if success
        header{counter}=local(1:end-1); %#ok<AGROW>
        local={};
        fseek(fid,start,'bof');
        temp=fscanf(fid,format,[column inf]);
        data{counter}=transpose(temp);
        counter=counter+1;
        if ~repeat
            break
        end
    end
end

if ~repeat
    data=data{1};
    header=header{1};
end

end