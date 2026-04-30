function setMode(object,mode,count)

communicate(object,':ACQUIRE:MODE %s',mode);
communicate(object,':ACQUIRE:NUMAVG %d',count);


end