% blockPZT Block the PZT interferometer leg
%
%    blockPZT(object);
%
% See also DAQUSB6009, unblockPZT, setSolenoid
%
function blockPZT(object)

setSolenoid(object,'pzt',true);

end