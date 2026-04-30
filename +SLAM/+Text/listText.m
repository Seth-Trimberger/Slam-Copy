% listText Text-based list selection
%
% The function creates text-based list selection.  It is functionally
% similar to MATLAB's listdlg command, with display and selection performed
% in the command window rather than a dialog box.  Users are prompted to
% make a selection until a valid integer index is entered or 'quit' is
% entered.
%
% List selections are defined by optional name/value pairs.
%    [index,choice]=listText(name,value,...);
% Valid options include:
%    -'list', which defines the items for selection with a string or
%    cellstr array.  The default value is {'Item A' 'Item B' 'Item C'}.
%    -'prompt', which defines text printed above the selection list.  The
%    default value is 'Select from the following:'.
%    -'mode', which controls whether user can make only one ('single') or
%    several selections ('multiple').  The default value is 'single'.
% The output "index" returns the user's integer selection(s), and the
% output "choice" reports the corresponding list item(s).  Both outputs are
% empty when the user enters 'quit'.
%
% When multiple selections are permitted, index values can be made
% explicitly (e.g., 1 2 3 5]) or with the colon operator (e.g., 1:3 5);
% square brackets are permitted but entirely optional.  Typing the word
% 'all' selects every available list index.
%
% See also listdlg
%
function [index,choice]=listText(varargin)

% manage input
Narg=nargin();
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');
data.List={'Item A' 'Item B' 'Item C'};
data.Prompt={'Select from the following:'};
data.Mode='single';
data.Delay=1;
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name) || isStringScalar(name),...
        'ERROR: invalid Item name');
    value=varargin{n+1};
    switch lower(name)
        case 'list'
            if ischar(value)
                value={value};
            end
            assert(iscellstr(value) || isstring(value),...
                'ERROR: invalid list');
            data.List=value;
        case 'prompt'
            if ischar(value)
                value={value};
            end
            assert(iscellstr(value) || isstring(value),...
                'ERROR: invalid prompt');
            data.Prompt=value;
        case 'mode'
            valid={'single' 'multiple'};
            assert(any(strcmpi(value,valid)),...
                'ERROR: mode must be ''%s'' or ''%s''',valid{:});
            data.Mode=lower(value);
        case 'delay'
            assert(isnumeric(value) && isscalar(value) && (value > 0),...
                'ERROR: invalid time delay');
            data.Delay=value;
        otherwise
            error('ERROR: invalid option name');
    end
end

% generate list
commandwindow();
fprintf('%s\n',data.Prompt{:});

N=numel(data.List);
digits=ceil(log10(N));
format=sprintf('   %%%dd : %%s\\n',digits);
for n=1:N
    fprintf(format,n,data.List{n});
end

% wait until user does something that makes sense
index=[];
valid=1:N;
if strcmp(data.Mode,'single')
    message='Selection (number or ''quit'') : ';
else
    message='Selection (numbers, ''all'', or ''quit'') : ';
end
while true()
    response=input(message,'s');
    try
        if strcmp(response,'quit')
            break
        elseif strcmp(response,'all')
            new=valid;
        else
            new=str2num(response,'Evaluation','restricted'); %#ok<ST2NM>
            if isempty(new)
                errmsg='Invalid selection';
                error('invalid');
            end
        end
        if strcmp(data.Mode,'single') && ~isscalar(new)
            errmsg='Multiple selection not permitted';
            error('muliple');
        end
        for m=1:numel(new)
            if ~any(new(m) == valid)
                errmsg='Invalid selection';
                error('invalid');
            end
        end
        index=new;
        break
    catch
        fprintf(repmat('\b',[1 numel(response)+1+numel(message)]));
        errmsg=sprintf('%s--try again',errmsg);
        fprintf(2,errmsg);
        pause(data.Delay);
        fprintf(repmat('\b',[1 numel(errmsg)]));
    end
end
choice=data.List(index);

end