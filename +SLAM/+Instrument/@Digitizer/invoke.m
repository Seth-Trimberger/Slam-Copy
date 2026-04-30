% invoke Perform digitizer action
%
% This method performs a requested digitizer action.  Requests may be
% simple:
%    invoke(object,action);
% or context-specific arguments.
%    invoke(object,action,arg1,arg2,...);
% Actions are automatically performed on every element of "object".
% Elements lacking the requested action are skipped and generate a warning.
%
% Actions beginning with "get" return data as a cell array.
%    result=invoke(object,action,...);
% Each element of result is itself a cell array with one element per output
% argument of the requested action.  
%
% See also Digitizer
%
function varargout=invoke(object,action,varargin)

% manage input
Narg=nargin();
assert(Narg > 1,'ERROR: action must be specified');
assert(ischar(action) || isStringScalar(action),'ERROR: invalid action');

% perform action
result=cell(size(object));
for n=1:numel(object)
    assert(~isempty(object(n).Library),...
        'ERROR: "%s" has not been linked to a command library',...
        object(n).Name)
    try
        local=object(n).Action.(action);
    catch
        warning('"%s" does not have action "%s"',object(n).Name,action);
        continue
    end    
    src=functions(local);
    src=src.workspace{1}.action;
    Nout=nargout(src);
    out=cell(1,Nout);
    [out{:}]=local(varargin{:});
     result{n}=out;
end

% manage output
if nargout() > 0
    varargout{1}=result;
end

end