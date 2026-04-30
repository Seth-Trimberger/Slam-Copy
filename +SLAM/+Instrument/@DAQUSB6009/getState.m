% getState Return the current solenoid state
%
% This method returns the current paddle state as a struct.
%    s = getState(object);
%    s.pzt    -> true if PZT leg is blocked
%    s.etalon -> true if Etalon leg is blocked
%    s.raw    -> raw uint8 bit pattern
%
% See also DAQUSB6009, setSolenoid
%
function s=getState(object)

s.pzt=logical(bitand(object.CurrentBitPattern,object.BIT_PZT));
s.etalon=logical(bitand(object.CurrentBitPattern,object.BIT_ETALON));
s.raw=object.CurrentBitPattern;

end