% create Interactive file creation
%
% This *static* method prompts users to interactively create a new ISP file.
%    object=ISPfile.create();
% A system dialog for file creation is displayed.  Once a file is chosen, a
% class object linked to that file is returned as an output.
%
% An optional default name can be specified.
%    object=ISPfile.create(default);
% The input "default" need not be an existing file--it can also specify a
% starting location.
%
% NOTE: selecting an existing file is permitted.  The system dialog may
% prompt the user that the file will be overwritten, but changes are not
% actually made by this method.
%
% See also SLAMfile, select
%
function object=create(default)

% manage input
if (nargin() < 1) || isempty(default)
    default='';
else
    if isStringScalar(default)
        default=char(default);
    end
    assert(ischar(default),'ERROR: invalid default name');
end

% file selection
[name,location]=uiputfile({'*.isp;*.ISP' 'ISP files'},'Select file',default);
if isnumeric(name)
    error('ERROR: no file selected');
end
file=fullfile(location,name);

persistent constructor
if isempty(constructor)
    constructor=handy.generateCall('ISPfile');
end
object=constructor(file);

end