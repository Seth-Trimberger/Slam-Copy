% unpark Unpark system
%
% This method unparks the system, allowing positions to be set.
%    unpark(object);
%
% See also Zaber, getParking, unpark
% 
function unpark(object)

communicate(object,'/tools parking unpark');

end