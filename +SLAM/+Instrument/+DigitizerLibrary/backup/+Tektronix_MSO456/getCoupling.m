function value=getCoupling(object)

N=numel(object.Channels);
value=cell(1,N);
for n=1:N
    ID=object.Channels{n};
    value{n}=communicate(object,':%s:Coupling?',ID);
end

end