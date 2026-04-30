% create Create *.taf file
%
% This *static* method creates a Thrifty Array Format file.
%    TAF.create(data,file,format);
% Mandatory input "data" define the file's array content, which must be
% real numeric data.  Optional input "file" specifies the name of the file
% to be created as a character array or scalar string.  Interactive
% selection is used when this argument is empty or omitted.  
%
% Optional input "format" controls how data is written to the file. When no
% format is specified, array elements are written in their native format,
% e.g. double-precision data uses 8 bytes following the IEEE 754 standard.
% Floating point data can be stored as scaled integers to reduce file size.
% This is done by specifying a format that uses fewer bits per element than
% the array itself. Selecting "format" to be any valid signed/unsigned
% integer type ('int8', 'uint16', etc.) linearly maps floating point data
% to stored integers.  The slope and intercept for converting integers back
% to floating point values is stored in the *.taf file.  Infinite slope and
% intercept values indicate that linear mapping is *not* used.
% 
% Additional arguments are interpreting as grid arrays.
%    TAF.create(data,file,format,grid1,grid2,...);
% Each grid array must match the length of the corresponding array
% dimension, e.g. "grid1" must have one element for each for of "data".
% Implicit (uniform) grid information is stored in the file, generating a
% warning if nonuniformities greater than 1 ppm are detected.  Empty values
% indicate no grid information, allowing lower dimensions to be skipped
% while higher ones are specified.  Excess grids are not used and generate
% a warning.
%
% Requesting an output:
%    object=TAF.create(...)
% returns an object linked to the created file.
%
% See also TAF, adjust
% 
function varargout=create(data,file,format,varargin)

persistent constructor
if isempty(constructor)
    constructor=handy.generateCall('TAF');
end

% manage input
Narg=nargin();
assert(Narg > 0,'ERROR: data array must be specified');
assert(isnumeric(data) && isreal(data) && ~issparse(data),...
    'ERROR: only real, non-sparse numeric data can be stored');

if (Narg < 2) || isempty(file)
    [file,location]=uiputfile(...
        {'*.taf;*.TAF' 'Thrifty Array Files (*.taf)'},...
        'Select file','mydata.taf');
    assert(~isnumeric(file),'ERROR: no file selected');
    file=fullfile(location,file);
else
    if isStringScalar(file)
        file=char(file);    
    end
    assert(ischar(file),'ERROR: invalid file name');
    [~,~,ext]=fileparts(file);
    assert(strcmpi(ext,'.taf'),'ERROR: invalid file extension');
end
[location,name,ext]=fileparts(file);
new=handy.portableFilename(name);
if ~strcmp(new,name)
    warning('File name was modified for portability');
end
file=fullfile(location,[new ext]);

if (Narg < 3) || isempty(format)    
    format=class(data);
elseif isnumeric(format)
    assert(isscalar(format) && any(format == [8 16 32 64]),...
        'ERROR: number of bits must be 8, 16, 32, or 64');
    switch format
        case 32
            format='single';
        case 64
            format='double';
        otherwise
            format=sprintf('uint%d',format);
    end
else
    try
        cast(0,format);
    catch
        error('ERROR: invalid data format');
    end   
end

% process data
slope=inf;
intercept=inf;
if isfloat(data) && contains(format,'int')
    keep=isfinite(data);    
    assert(any(keep(:)),...
        'ERROR: at least one finite element needed for integer storage');
    temp=data(keep);
    dmin=min(temp);
    dmax=max(temp);
    denom=cast(intmax(format)-intmin(format),class(data));    
    slope=(dmax-dmin)/denom;
    intercept=dmin-slope*cast(intmin(format),class(data));
    data=(data-intercept)/slope;
    data=cast(data,format);
elseif ~strcmp(class(data),format)
    data=cast(data,format);
end

% write header
local=fileparts(mfilename('fullpath'));
fid=fopen(fullfile(local,'introduction.txt'),'r');
opening=fread(fid,[1 inf],'uchar');
fclose(fid);

if isfile(file)    
    fid=fopen(file,'r+','ieee-le');
    assert(fid > 0,'ERROR: unable to modify existing file');    
    trim=true();
else    
    fid=fopen(file,'w','ieee-le');    
    assert(fid > 0,'ERROR: unable to create requested file');    
    trim=false();
end

offset=1024;
fwrite(fid,repmat(' ',[1 offset]),'char');
frewind(fid);

fwrite(fid,'TAF ','uint8');
fwrite(fid,1,'uint8'); % major version number
fwrite(fid,1,'uint8'); % minor version number
fwrite(fid,0,'uint8'); % generic array
fwrite(fid,newline,'uint8');

fwrite(fid,opening,'uchar');
fseek(fid,offset,'bof');
switch format
    case 'single'
        type='flt32';
    case 'double'
        type='flt64';
    otherwise
        type=format;
end
type=uint8(type);
type(8)=0;
fwrite(fid,type,'uchar');
fwrite(fid,[intercept slope],'double');

L=size(data);
fwrite(fid,numel(L),'uint64');
for k=1:numel(L)
    fwrite(fid,L(k),'uint64');
    fwrite(fid,[1 1],'double');
end

% write data
fwrite(fid,data,format);

if trim
    bytes=ftell(fid);
end
fclose(fid);
if trim
    handy.truncate(file,bytes);
end

object=constructor(file);

% adjust grid if any were passed
M=numel(varargin);
if M > numel(L)
    warning('TAF:ExcessGrids','Ignoring excess grid(s)');
    varargin=varargin(1:numel(L));
end
for n=1:numel(varargin)
    grid=varargin{n};
    if isempty(grid)
        continue
    end
    assert(isnumeric(grid) && all(isfinite(grid)),...
        'ERROR: invalid grid request for dimension %d',n);
    assert(numel(grid) == L(n),...
        'ERROR: incompatible grid request for dimension %d',n);
    delta=diff(grid);
    step=(grid(end)-grid(1))/(numel(grid)-1);
    ratio=delta/step;
    maxerr=max(abs(ratio-1));
    tolerance=1e-6;    
    if maxerr > tolerance
        warning('TAF:UniformGrid',...
            'Non-uniform grid detected at the %g level',maxerr);
    end
    span=grid([1 end]);
    adjust(object,n,'span',span);
end

% manage output
if nargout > 0
    varargout{1}=object;
end

end