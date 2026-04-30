function result=getActive(object)

keep=false(size(object.Channels));
for n=1:numel(object.Channels)
    ID=object.Channels{n};
    response=communicate(object,':DISPLAY:WAVEVIEW1:%s:STATE?;',ID);
    if logical(sscanf(response,'%g',1))
        keep(n)=true();
    end
end
result=object.Channels(keep);

end