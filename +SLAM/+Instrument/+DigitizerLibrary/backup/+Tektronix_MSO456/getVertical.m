function [span,offset]=getVertical(object)

N=numel(object.Channels);
offset=nan(N,1);
span=nan(N,2);
for n=1:N
    buffer=communicate(object,':%s:OFFSET?; POSITION?; SCALE?',...
        object.Channels{n});
    buffer=strrep(buffer,';',' ');
    data=sscanf(buffer,'%g');    
    offset(n)=data(1);
    position=data(2);
    scale=data(3);
    span(n,:)=([-1 +1]/2*object.Divisions(2)-position)*scale...
        +offset(n);
end

end