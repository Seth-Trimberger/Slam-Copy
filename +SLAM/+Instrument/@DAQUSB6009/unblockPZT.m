% unblockPZT Unblock the PZT interferometer leg
%
%    unblockPZT(object);
%
% See also DAQUSB6009, blockPZT, setSolenoid
%
function unblockPZT(object)

setSolenoid(object,'pzt',false);

end