% connect Establish VISA connection to the Verdi laser
%
% This *static* method establishes a VISA serial connection with the laser.
%    laser = Verdi.connect(resource);
% Mandatory input "resource" specifies a VISA address string such as
% 'ASRL4::INSTR'.
%
% Echo is automatically disabled during connection to ensure clean
% command/response communication.
%
% See also Verdi, communicate
%
function object=connect(resource)

if (nargin() < 1) || isempty(resource)
    error('Verdi:connect','VISA resource must be specified');
end
if ~(ischar(resource) || isStringScalar(resource))
    error('Verdi:connect','invalid VISA resource');
end
resource=char(resource);

try
    device=visadev(resource);
catch ME
    throwAsCaller(ME);
end

configureTerminator(device,'CR/LF');

persistent constructor
if isempty(constructor)
    constructor=handy.generateCall('Verdi');
end
object=constructor(device);

% disable echo for clean responses
communicate(object,'ECHO=0');

fprintf('Verdi laser connected on %s\n',resource);

end