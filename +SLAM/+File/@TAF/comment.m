% comment Manage text comments
%
% The methods manages text comments in the file.
%    comment(object,entry,mode);
% Optional input "entry" is a character/string/cellstr array that will be
% written at the end of the file, defaulting to ''.  Optional input "mode"
% controls how that text written.  The default mode 'add' appends "entry"
% to the file, preserving previously written comments (in any).  
%    comment(object,entry); % add comments
% Newline characters are automatically inserted between previous and new
% comments as well as between string/cellstr elements "entry".  The mode
% 'reset' removes previous comments before adding the new entry.
%    comment(object,entry,'reset');
% Using reset mode with an empty entry:
%    comment(object,'','reset');
% removes all file comments.  
% 
% Both 'reset' and 'add' mode can be applied to an object array.  A third
% mode is available for scalar objects only.
%    comment(object,entry,'type');
% This mode allows comments to be interactively typed in a dialog box.  The
% default text in this box is based on "entry" or the current comments when
% the former is empty.
%
% See also TAF
%
function comment(object,entry,mode)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(entry)
    entry='';
else
    if isstring(entry) || iscellstr(entry)
        entry=sprintf('%s\n',entry{:});
    else
        assert(ischar(entry),'ERROR: invalid comment');
    end
end

if (Narg < 3) || isempty(mode) || strcmpi(mode,'add')
    mode='add';
elseif strcmpi(mode,'reset')
    mode='reset';
elseif strcmp(mode,'type')
    mode='type';
else
    error('ERROR: invalid comment mode');
end

% comment modes
if strcmp(mode,'type')
    assert(isscalar(object),...
        'ERROR: comments must be typed one object at a time');
    default=entry;
    if isempty(default)
        default=object.Info.Comments;
    end
    entry=typeComments(object,default);   
    mode='reset';
end

for n=1:numel(object)
    try
        info=object(n).Info;
    catch ME
        throwAsCaller(ME);
    end   
    if strcmp(mode,'add')
        fid=fopen(object.Target,'a');
        if ~isempty(info.Comments)
            fwrite(fid,newline(),'uchar');
        end
    elseif strcmp(mode,'reset')
        fid=fopen(object.Target,'r+');
        fseek(fid,info.CommentOffset,'bof');
    end
    fwrite(fid,entry,'uchar');
    bytes=ftell(fid);
    fclose(fid);
    handy.truncate(object(n).Target,bytes);
    object(n).PreviousInfo=[];
end

end


%%
function entry=typeComments(object,default)

response=inputdlg('Comments',object.Name,[10 40],{default});
if isempty(response)
    return
end
response=response{1};

entry='';
for row=1:size(response,1)
    buffer=strip(response(row,:),'right');    
    if row > 1
        entry=sprintf('%s\n%s',entry,buffer);
    else
        entry=buffer;
    end
end

end