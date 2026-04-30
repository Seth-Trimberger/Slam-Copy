function bandwidth=getBandwidth(object)

N=numel(object.Channels);
bandwidth=nan(1,N);
for n=1:N
    ID=object.Channels{n};
    temp=communicate(object,':%s:BANDWIDTH:ACTUAL?',ID);
    bandwidth(n)=sscanf(temp,'%g',1);
end

end