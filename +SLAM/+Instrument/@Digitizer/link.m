% link Define command library
%
% This method defines the command library that specifies valid digitizer
% features and actions.
%    link(object,library);
% The input "library" can explicitly reference a command library namespace
% or reference a standard library name.  Standard libraries are denoted
% with an initial dot, e.g. '.Tektronix_456'.
%
% The list of standard command libraries can be printed in the command
% window:
%    link(object,'-show');
% or returned as a cellstr array.
%    list=link(object,'-show'); 
%
% Automatic library selection is requested as follows.
%    link(object,'-auto');
% This process attemps to find a standard library compatible with the
% current device.
%
% See also Digitizer
% 
function varargout=link(object,library)

persistent Standard StandardList
if isempty(Standard)
    location=fileparts(fileparts(mfilename("fullpath")));
    Standard=extractAfter(location,'+');
    Standard=strrep(Standard,[filesep '+'],'.');
    Standard=[Standard '.DigitizerLibrary'];
    ns=matlab.metadata.Namespace.fromName(Standard);
    temp=ns.InnerNamespaces;
    StandardList=cell(size(temp));
    for n=1:numel(temp)
        StandardList{n}=temp(n).Description;
    end
end

% manage object arrays
Narg=nargin();

if Narg < 2
    library='';
end

N=numel(object);
if N > 1
    for n=1:N
        link(object(n),library)
    end
    return
end

% manage input
if isempty(library) || strcmpi(library,'-auto')
    success=false();
    for n=1:numel(StandardList)
        try
            library=[Standard '.' StandardList{n}];
            feval([library '.configure'],object,'query');
            success=true();
            break
        catch
            continue
        end
    end
    assert(success,'ERROR: unable to automatically standard library');
elseif strcmpi(library,'-show')
    if nargout() > 0
        varargout{1}=StandardList;
        return
    end
    fprintf('Standard library includes:\n');
    for n=1:numel(StandardList)
        fprintf('   .%s\n',StandardList{n});
    end
    return
else
    if isStringScalar(library)
        library=char(library);
    end
    assert(ischar(library),'ERROR: invalid command library');
    if startsWith(library,'.')
        library=[Standard library];
    else
        try
            [~]=matlab.metadata.Namespace.fromName(library);
        catch
            error('ERROR: invalid command library');
        end
    end
end

% configure and add actions
object.Feature=feval([library '.configure'],object);

ActionList=struct();
ns=matlab.metadata.Namespace.fromName([library '.action']);
list=ns.FunctionList;
for n=1:numel(list)
    action=[ns.Name '.' list(n).Name];
    ActionList.(list(n).Name)=@(varargin) feval(action,object,varargin{:});
end
object.Action=ActionList;

object.Library=library;

end