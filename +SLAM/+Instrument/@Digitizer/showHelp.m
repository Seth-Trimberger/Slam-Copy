% showHelp Display action help
%
% This method displays the actions provided by the digitizer's command
% library.
%    showHelp(object,action);
% Optional input "action" specifies a particular action of interest.  When
% this input is empty/omitted, a list of available actions is printed in
% the command window.  
%
% See also Digitizer, link
%
function showHelp(object,action)

library=object(1).Action;
assert(~isempty(library),'ERROR: digitizer not linked to command library');
name=fieldnames(library);

% manage input
if (nargin() < 2) || isempty(action)
    fprintf('Defined actions:\n');
    for n=1:numel(name)
        fprintf('\t%s\n',name{n});
    end
    return
end

assert(ischar(action) || isStringScalar(action),'ERROR: invalid action');
assert(any(strcmpi(action,name)),...
    'ERROR: "%s" is not a defined action',action);

location=sprintf('%s.action.%s',object.Library,action);
help(location);

end