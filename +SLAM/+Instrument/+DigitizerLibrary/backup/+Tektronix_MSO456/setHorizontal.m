function setHorizontal(object,range,rate)

communicate(object,':HORIZONTAL:MODE MANUAL');
duration=diff(range);
position=-range(1)/duration*100;
communicate(object,':HORIZONTAL:MODE:SAMPLERATE %g',rate);
temp=communicate(object,':HORIZONTAL:MODE:SAMPLERATE?');
rate=sscanf(temp,'%g',1);
points=ceil(duration*rate);
communicate(object,':HORIZONTAL:MODE:RECORDLENGTH %.0f',points);
communicate(object,':HORIZONTAL:POSITION %g',position);

end