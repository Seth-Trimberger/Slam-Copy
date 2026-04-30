% crop Crop array
%
% This method crops array content to the current region of interest.
%    crop(object);
% Object arrays are permitted, each referencing their own ROI.  
%
% NOTE: cropping is a destructive operation, eliminating all information
% outside the ROI.  If one is not absolutely sure about this, the backup
% method should be called first.
%
% See also TAF, backup, setROI
%
function crop(object)

% manage object arrays
if ~isscalar(object)
    for m=1:numel(object)
        crop(object(m));
    end
    return
end

% verify file
try
    info=object.Info;
catch ME
    throwAsCaller(ME);
end

% perform crop
map=object.MemoryMap;
map.Writable=true();

subscript=cell(1,info.Dimensions);
L=ones(1,info.Dimensions);
bound=object.ROI;
for m=1:info.Dimensions
    L(m)=(diff(bound(m,:))+1);
    subscript{m}=bound(m,1):bound(m,2);
end
map.Data.Array(1:prod(L))=map.Data.Array(subscript{:});

object.MemoryMap=[];

fid=fopen(object.Target,'r+');
skip=4*8; % bits, intercept, slope, and array dimensions
fseek(fid,info.HeaderOffset+skip,'bof'); % absolute move
for m=1:info.Dimensions
    fwrite(fid,L(m),'uint64'); % grid length
    start=info.Start(m)+(bound(m,1)-1)*info.Step(m);
    fwrite(fid,start,'double'); % grid start
    fwrite(fid,info.Step(m),'double'); % grid step
end
fseek(fid,prod(L)*info.Bits/8,'cof'); % relative move
if ~isempty(info.Comments)
    fwrite(fid,info.Comments,'char');
end

bytes=ftell(fid);
fclose(fid);
handy.truncate(object.Target,bytes);

setROI(object);

end