% clearSystem Clear acquisition system
%
% This function clears last acquisition, eliminated all stored data and
% wiping the local display.
%    clearSystem(object);
%
% NOTE: this is a quick memory clear, not the comprehensive Teksecure
% process that takes 3-5 minutes
%
function clearSystem(object)

assert(isscalar(object),...
    'ERROR: actions must be performed one object at a time');

communicate(object,':CLEAR');

end