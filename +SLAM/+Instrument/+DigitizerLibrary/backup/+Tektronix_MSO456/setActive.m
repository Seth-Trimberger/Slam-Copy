function setActive(object)

for n=1:numel(object.Channels)
    if any(strcmpi(object.Channels{n},object.SelectedChannel))
        communicate(object,'DISPLAY:WAVEVIEW1:%s:STATE ON',...
            object.Channels{n});
    else
        communicate(object,'DISPLAY:WAVEVIEW1:%s:STATE OFF',...
            object.Channels{n});
    end
end

end