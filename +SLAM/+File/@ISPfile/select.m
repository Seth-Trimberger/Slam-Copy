% select Interactive file selection
%
% This *static* method prompts users to interactively select an existing
% ISP file.
%    object=ISPfile.select();
% A system dialog for file creation is displayed.  Once a file is chosen, a
% class object linked to that file is returned as an output.
%
% An optional default name can be specified.
%    object=ISPfile.select(default);
% The input "default" need not be an existing file--it can also specify a
% starting location.
%
% See also ISPfile, create
%
function object=select(default)

% manage input
if (nargin() < 1) || isempty(default)
    default='demonstration.isp';
else
    if isStringScalar(default)
        default=char(default);
    end
    assert(ischar(default),'ERROR: invalid default name');
end

% file selection
[name,location]=uigetfile({'*.isp;*.ISP' 'ISP files'},'Select file',default);
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