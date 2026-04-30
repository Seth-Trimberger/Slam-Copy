% connect Establish VISA connection
%
% This *static* method establishes a VISA connection with the digitizer
%    object=VisaDigitizer.connect(resource);
% Mandatory input "resource" specifies an absolute VISA address, an valid
% VISA alias, or the TCP/IP address (e.g., '10.150.1.100') from which a
% VISA address can be constructed.  The output "object" must be linked to a
% command library to become useful.
%
% See also VisaDigitizer, link
%
function object=connect(resource)

Narg=nargin();
assert((Narg >= 1) && ~isempty(resource),...
    'ERROR: VISA resource must be specified');
assert(ischar(resource) || isStringScalar(resource),...
    'ERROR: invalid VISA resource');
resource=char(resource);

if (sum(resource == '.') ==3) && ~contains(resource,':')
    resource=sprintf('TCPIP0::%s::inst0::INSTR',resource);
end

list=visadevfind();
match=false();
for n=1:numel(list)
    if any(strcmp(resource,[list(n).ResourceName list(n).Alias]))
        match=true();
        device=list(n);
        break
    end
end

if ~match
    try
        device=visadev(resource);
    catch ME
        throwAsCaller(ME);
    end
end

configureTerminator(device,'LF');

persistent constructor
if isempty(constructor)
    constructor=handy.generateCall('VisaDigitizer');
end
object=constructor(device);

end