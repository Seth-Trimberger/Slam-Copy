% blockEtalon Block the Etalon interferometer leg
%
%    blockEtalon(object);
%
% See also DAQUSB6009, unblockEtalon, setSolenoid
%
function blockEtalon(object)

setSolenoid(object,'etalon',true);

end