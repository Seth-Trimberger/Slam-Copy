function setTrigger(object,source,level,slope)

communicate(object,':TRIGGER:A:MODE NORMAL; TYPE EDGE');
communicate(object,':TRIGGER:A:EDGE:SOURCE %s',source);
if contains(source,'CH','IgnoreCase',true())
    communicate(object,':TRIGGER:A:LEVEL:%s %g',source,level);
elseif strcmpi(source,'AUXILIARY')
    communicate(object,':TRIGGER:AUXLEVEL %g',level);
end
communicate(object,':TRIGGER:A:EDGE:SLOPE %s',slope);

end