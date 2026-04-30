function setVertical(object,span,offset)

scale=(span(2)-span(1))/object.Divisions(2);
position=-(span(1)-offset)/scale-object.Divisions(2)/2;

for n=1:numel(object.Channels)
    if any(strcmp(object.Channels{n},object.SelectedChannel))
            communicate(object,':%s:OFFSET %g; POSITION %g; SCALE %g',...
            object.Channels{n},offset,position,scale);
    end
end

end