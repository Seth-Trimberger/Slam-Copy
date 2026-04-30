function label=generateGridLabel(object)

info=object.Info;

N=info.Dimensions;
label=cell(1,N);
pattern=cell(1,N);
for n=1:N
    label{n}=sprintf('Grid %d',n);
    pattern{n}=sprintf('Grid %d:',n);
end

buffer=info.Comments;
while ~isempty(buffer)
    temp=extractBefore(buffer,newline());
    if isempty(temp)
        temp=buffer;
        buffer='';        
    else
        buffer=extractAfter(buffer,newline);
    end
    for n=1:N
        if startsWith(temp,pattern{n})
            label{n}=extractAfter(temp,pattern{n});            
        end
    end
end

end