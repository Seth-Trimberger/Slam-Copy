% select Select file(s)
%
% This *static* method supports interactive and multiple file selection.
% When called with no input:
%    object=TAF.select();
% the user is prompted to select one or more files.  Multiple files can be
% selected explicitly:
%    object=TAF.select(file1,file2,...);
% with wild card search patterns (e.g., '*.taf'):
%    object=TAF.select(pattern1,pattern2,...);
% or any combination of the both (in any order).
%    object=TAF.select(file1,pattern1,...);
% The output "object" is an array of TAF objects. 
% 
% There is no requirement that multiple files be selected--individual
% files can be selected interactively or explicitly.  Files lacking the
% '*.taf' extension are automatically excluded from wild card pattern
% searches.  Explicit individual files can also be passed to the
% constructor.
%
% See also TAF
%
function object=select(varargin)

% function handles for constructor and static method (robust to namespace)
persistent constructor
if isempty(constructor)
    constructor=handy.generateCall('TAF');
end

% interactive selection
if nargin() < 1
    [name,location]=...
        uigetfile({'*.taf;*.TAF' 'Thrifty Array Format files (*.taf)'},...
        'Select thrifty array file','MultiSelect','on');
    assert(~isnumeric(name),'ERROR: no file selected');    
    if ischar(name)
        name={name};
    end
    N=numel(name);
    arg=cell(1,N);
    for n=1:N
        arg{n}=fullfile(location,name{n});
    end   
else
    arg={};
    for m=1:numel(varargin)
        name=varargin{m};
        if isStringScalar(name)
            name=char(name);
        end
        assert(ischar(name),'ERROR: invalid file selection');
        if contains(name,'*')
            list=dir(name);
            N=numel(list);
            name=cell(1,N);
            keep=false(size(list));
            for n=1:N
                if list(n).isdir
                    continue
                end
                [~,~,ext]=fileparts(list(n).name);
                if ~strcmpi(ext,'.taf')
                    continue
                end
                name{n}=fullfile(list(n).folder,list(n).name);
                keep(n)=true();
            end
            name=name(keep);
        else
            name={name};
        end       
        if isempty(arg)
            arg=name;
        else
            arg=[arg name]; %#ok<AGROW>
        end
    end
end

% process selection(s)
M=numel(arg);
for m=1:M
    try
        new=constructor(arg{m});
    catch ME
        throwAsCaller(ME);
    end
    if m == 1
        object=repmat(new,[1 M]);
    else
        object(m)=new;
    end
end

end