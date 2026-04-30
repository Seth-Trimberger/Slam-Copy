% getPosition Get current position
%
% The method gets the current system position.
%    value=getPosition(object);
% The output "value" indicates position at the moment the command is
% received.  This 
%
% See also Zaber, setPosition
%
function value=getPosition(object)

[~,report]=communicate(object,'/get pos');
value=sscanf(report.Data,'%g',1);

end