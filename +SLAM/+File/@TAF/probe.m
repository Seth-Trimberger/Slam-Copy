% probe Query file content
%
% This method probes the file:
%    probe(object);
% updating the Info property.
%
% See also TAF, map, read
%
function probe(object)

assert(isscalar(object),'ERROR: TAF files must be probed one at a time');

% probe individual file
fid=fopen(object.Target,'r','ieee-le');
CU=onCleanup(@() fclose(fid));

temp=transpose(fread(fid,8,'uint8'));
assert(strcmp(char(temp(1:3)),'TAF') && (temp(end) == 10),...
    'ERROR: invalid TAF file');
info.MajorVersion=uint8(temp(5));
info.MinorVersion=uint8(temp(6));
if temp(4) == 32 % space character
    info.TypeCode=uint8(temp(7)); 
else
    info.TypeCode=uint8(0); % legacy opening was TAF(xx)
end

% read header
offset=1024;
info.HeaderOffset=offset;
fseek(fid,offset,'bof');
atype=char(transpose(fread(fid,8,'uchar')));
atype=deblank(atype);
switch atype
    case 'flt32'
        info.Format='single';
        info.Bits=32;
    case 'flt64'
        info.Format='double';
        info.Bits=64;
    otherwise
        try
            temp=cast(0,atype); % integer formats
            info.Format=class(temp);
            temp=whos('temp');
            info.Bits=8*temp.bytes;
        catch % legacy mode
            fseek(fid,offset,'bof');
            info.Bits=fread(fid,1,'uint64');
            switch info.Bits
                case 8
                    info.Format='uint8';
                    info.Bits=8;
                case 16
                    info.Format='uint16';
                    info.Bits=16;
                case 32
                    info.Format='single';
                    info.Bits=32;
                case 64
                    info.Format='double';
                    info.Bits=64;
                otherwise
                    error('ERROR: invalid data format');
            end            
        end
end

info.Intercept=fread(fid,1,'double');
info.Slope=fread(fid,1,'double');
info.Dimensions=fread(fid,1,'uint64');
temp=nan(1,info.Dimensions);
info.Size=temp;
info.Start=temp;
info.Step=temp;
for k=1:info.Dimensions
    info.Size(k)=fread(fid,1,'uint64');
    info.Start(k)=fread(fid,1,'double');
    info.Step(k)=fread(fid,1,'double');
end

info.DataOffset=ftell(fid);

% read/parse comments
points=prod(info.Size);
bytes=points*info.Bits/8;
fseek(fid,bytes,'cof');

info.CommentOffset=ftell(fid);
info.Comments=fread(fid,[1 inf],'*char');

% check time stamp
file=dir(object.Target);
info.datenum=file.datenum;

object.PreviousInfo=info;

% update memory map
new=memmapfile(object.Target);
new.Offset=info.DataOffset;
new.Format={info.Format info.Size 'Array'};
object.MemoryMap=new;

end