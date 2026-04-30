% get horizontal range and sample rate
function [range,rate]=getHorizontal(object)

temp=communicate(object,':HORIZONTAL:ACQDURATION?');
duration=sscanf(temp,'%g',1);
temp=communicate(object,':HORIZONTAL:POSITION?');
position=sscanf(temp,'%g',1);
left=-duration*position/100;
right=+duration*(1-position/100);
result.Range=[left right];
temp=communicate(object,':HORIZONTAL:DELAY:TIME?');
delay=sscanf(temp,'%g',1);
range=result.Range+delay;
temp=communicate(object,':HORIZONTAL:MODE:SAMPLERATE?');
rate=sscanf(temp,'%g',1);

end