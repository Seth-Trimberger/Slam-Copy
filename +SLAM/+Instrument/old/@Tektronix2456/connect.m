% connect Make digitizer connection
%
% This *static* method makes a digitizer connection based on a specified
% text pattern.
%   object=Tektronix456.connect(pattern);
% Optional input "pattern" can indicate the complete VISA address, the
% VISA alias (if any), or serial number for the digitizer of interest.
% When this input is empty or omitted, a connection is made to the first
% listed digitizer.
%
% See also Tektronix2456
%
function object=connect(pattern)

persistent self constructor
if isempty(self)
    constructor=mfilename('class');
    self=[constructor '.connect'];
end

% scan connections
if nargin() < 1
    fprintf('Looking for VISA devices...');
    try
        report=visadevlist();
    catch ME
        fprintf('none found\n');
        throwAsCaller(ME);
    end
    N=size(report,1);
    fprintf('%d found\n',N);
    success=false();
    for n=1:N
        fprintf('Trying %s...',report.ResourceName(n));
        try
            object=feval(self,report.ResourceName(n));
        catch
            fprintf('moving on\n');
            continue
        end
        fprintf('success\n');
        success=true();
        break
    end
    assert(success,'ERROR: no supported digitizer found');
    return
end

assert(ischar(pattern) || isStringScalar(pattern),...
    'ERROR: invalid search pattern');
pattern=char(pattern);

% look for existing connection, make new one as needed
previous=visadevfind();
match=false();
for n=1:numel(previous)
    name{1}=char(previous(n).ResourceName);
    name{2}=char(previous(n).Alias);
    if any(strcmpi(pattern,name))
        dev=previous(n);
        match=true();
        break
    end
end

if ~match
    try
        dev=visadev(pattern);
    catch ME
        throwAsCaller(ME);
    end
end

% create object
object=feval(constructor,dev);

end