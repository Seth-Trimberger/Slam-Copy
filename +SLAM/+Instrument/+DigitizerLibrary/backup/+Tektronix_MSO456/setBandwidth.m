function setBandwidth(object,value) 

for n=1:numel(object.Channels)
    if any(strcmpi(object.Channels{n},object.SelectedChannel))
        if isfinite(value)
            communicate(object,':%s:BANDWIDTH %g',...
                object.Channels{n},value);
        else
            communicate(object,':%s:BANDWIDTH FULL',object.Channels{n});
        end
    end
end

end