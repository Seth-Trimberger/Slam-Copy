function [source,level,slope]=getTrigger(object)

temp=communicate(object,':TRIGGER:A:EDGE:SOURCE?');
source=temp;
if contains(source,'CH','IgnoreCase',true())
    temp=communicate(object,':TRIGGER:A:LEVEL:%s?',source);
elseif strcmpi(source,'AUXILIARY')
    temp=communicate(object,':TRIGGER:AUXLEVEL?');
else
    temp='nan';
end
level=sscanf(temp,'%g',1);
slope=communicate(object,':TRIGGER:A:EDGE:SLOPE?');

end