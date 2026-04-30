% getParking Get parking state
%
% This method queries the current parking state.
%    state=getParking(object);
%
% See also Zaber, park, unpark 
%
function state=getParking(object)

[~,report]=communicate(object,'/get parking.state');

if strcmp(report.Data,'0')
    state='unparked';
else
    state='parked';
end

end