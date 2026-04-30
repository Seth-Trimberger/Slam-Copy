function setCoupling(object,value) 

for n=1:numel(object.Channels)
    if any(strcmpi(object.Channels(n),object.SelectedChannel))
        communicate(object,':%s:COUPLING %s',object.Channels{n},value);
     end
end
        
end