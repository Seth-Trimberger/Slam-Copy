% setSolenoid Set a single paddle solenoid on or off
%
% This method controls an individual beam-blocking paddle.
%    setSolenoid(object,legName,state);
% Input "legName" must be 'pzt' or 'etalon' (case-insensitive).
% Input "state" must be true/1 (block beam) or false/0 (unblock beam).
%
% See also DAQUSB6009, blockPZT, blockEtalon, unblockAll
%
function setSolenoid(object,legName,state)

if (nargin() < 3) || isempty(legName) || isempty(state)
    error('DAQUSB6009:setSolenoid','leg name and state are required');
end

checkConnected(object);
bit=legNameToBit(object,legName);

if state
    newPattern=bitor(object.CurrentBitPattern,bit);
else
    newPattern=bitand(object.CurrentBitPattern,bitcmp(bit,'uint8'));
end

writePattern(object,newPattern);
fprintf('DAQUSB6009: %s leg -> %s\n',upper(char(legName)),stateLabel(state));

end

%% local helpers
function checkConnected(object)
    if ~object.IsConnected
        error('DAQUSB6009:setSolenoid','DAQ not connected');
    end
end

function bit=legNameToBit(~,legName)
    switch lower(char(legName))
        case 'pzt'
            bit=uint8(1);
        case 'etalon'
            bit=uint8(2);
        otherwise
            error('DAQUSB6009:setSolenoid',...
                'unknown leg name "%s" — use "pzt" or "etalon"',legName);
    end
end

function lbl=stateLabel(state)
    if state
        lbl='BLOCKED';
    else
        lbl='UNBLOCKED';
    end
end