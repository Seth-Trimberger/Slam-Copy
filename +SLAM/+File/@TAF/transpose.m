% transpose Interchange rows and columns
%
% This method transposes the stored array.
%    transpose(object);
% The interchange of rows and columns is accompanied by a grid swap and ROI
% update.  Type codes may be revised, e.g. column arrays (1) become row
% arrays (2) and vice versa.
%
% See also TAF
%
function transpose(object)

for n=1:numel(object)    
    try
        info=object(n).Info;
    catch ME
        throwAsCaller(ME);
    end
    % transpose array
    map=object(n).MemoryMap;
    map.Writable=true();
    map.Data.Array=transpose(map.Data.Array);
    map.Writable=false();
    % update header
    fid=fopen(object(n).Target,'r+','ieee-le');
    fseek(fid,info.HeaderOffset,'bof');
    fseek(fid,4*8,'cof'); % skip data format, intercept/slope, dimensions
    for k=2:-1:1
        fwrite(fid,info.Size(k),'uint64');
        fwrite(fid,info.Start(k),'double');
        fwrite(fid,info.Step(k),'double');
    end
    fclose(fid);
    % update ROI
    previous=object(n).ROI;
    object(n).ROI(1,:)=previous(2,:);
    object(n).ROI(2,:)=previous(1,:);
    % update type
     switch info.TypeCode
        case 1
            setType(object(n),2);
        case 2
            setType(object(n),1);
     end
     object(n).PreviousInfo=[];
end

end