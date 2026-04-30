% stop Stop motion
%
% This method immediately stops motion.
%    stop(object);
%
% See also Zaber, resume
%
function stop(object)

communicate(object,'/stop');

end