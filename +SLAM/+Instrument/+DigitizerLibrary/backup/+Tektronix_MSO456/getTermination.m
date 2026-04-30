function value=getTermination(object)

N=numel(object.Channels);
value=nan(1,N);
for n=1:N
    ID=object.Channels{n};
    temp=communicate(object,':%s:Termination?',ID);
    value(n)=sscanf(temp,'%g',1);
end

end