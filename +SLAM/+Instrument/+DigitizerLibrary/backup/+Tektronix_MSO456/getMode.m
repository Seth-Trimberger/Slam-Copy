function [mode,count]=getMode(object)

mode=communicate(object,':ACQUIRE:MODE?');

temp=communicate(object,':ACQUIRE:NUMAVG?');
count=sscanf(temp,'%d');

end