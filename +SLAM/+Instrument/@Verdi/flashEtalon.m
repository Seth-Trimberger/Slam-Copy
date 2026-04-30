% flashEtalon Flash the etalon
%
% This method triggers an etalon flash (FLASH=1) to recenter the
% single-frequency lasing mode.  This is called automatically during
% shot preparation to prevent multi-mode lasing of the 10W Verdi.
%    flashEtalon(object);
%
% See also Verdi
%
function flashEtalon(object)

fprintf('Flashing etalon\n');
communicate(object,'FLASH=1');
pause(0.2);

end