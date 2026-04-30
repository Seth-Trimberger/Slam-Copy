function setTermination(object,value)

for n=1:numel(object.Channels)
    if any(strcmpi(object.Channels(n),object.SelectedChannel))
        communicate(object,':%s:TERMINATION %g',object.Channels{n},value);
     end
end

end