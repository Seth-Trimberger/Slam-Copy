% unblockEtalon Unblock the Etalon interferometer leg
%
%    unblockEtalon(object);
%
% See also DAQUSB6009, blockEtalon, setSolenoid
%
function unblockEtalon(object)

setSolenoid(object,'etalon',false);

end