% demonstrate Create example file(s)
%
% This method creates demonstration *.taf files.
%    TAF.demonstrate(example);
% Optional input "example" selects a particular demonstration by numeric
% value.  Supported examples include:
%    -0 for a generic array (11x11 magic square).
%    -1 for a column-based 2D array (default).  Examples 1.1, 1.2, and 1.3
%    are variations with different numeric precision.
%    -2 for a row-based 2D array (transpose of example 1).
%    -3 for a gray scale image.  Example 3.1 is a multi-layer image, which
%    can be interpreted as three individual images or an RGB image.
% Example files are named 'demonstration%g.taf', with the example number
% printed in the %g format specification, overwriting existing files
% automatically.
%
% The command:
%    TAF.demonstrate('all');
% generates all of the above examples.  Multiple examples can also
% be requested specifically.
%    TAF.demonstrate([1 2]); % generate example 1 and 2
%
% Requesting an output:
%    object=TAF.demonstrate(example);
% returns an object linked to the created file(s);
%
% See also TAF, create
%
function varargout=demonstrate(example,file)

persistent constructor create self
if isempty(constructor)
    constructor=handy.generateCall('TAF');
    create=handy.generateCall('TAF.create');
    self=handy.generateCall('TAF.demonstrate');
end

% manage input
Narg=nargin();
if (Narg < 1) || isempty(example)
    example=1;
elseif strcmpi(example,'all')  
    example=[0 1 1.1 1.2 1.3 2 3 3.1];    
else
    assert(isnumeric(example),'ERROR: invalid demo number');
end

if (Narg < 2) || isempty(file)
    standard=true();
else
    assert(isscalar(example),...
        'ERROR: manual naming must be done one example at a time');
    standard=false();
end

% generate demonstration file(s)
N=numel(example);
for n=1:N
    if standard
        file=sprintf('demonstration%g.taf',example(n));
        fprintf('Creating example "%s"...',file)
    end
    switch example(n)
        case 0
            data=magic(11);
            create(data,file);            
            new=constructor(file);
            comment(new,'Generic array example');
        case 1            
            time=transpose(linspace(-1,1,75));
            data=[time time.^2 time.^3];
            new=create(data,file,'',time);     
            setType(new,1);
            comment(new,'Column array example with double precision');
        case 1.1            
            time=transpose(linspace(-1,1,75));
            data=[time time.^2 time.^3];
            new=create(data,file,'single',time);     
            setType(new,1);
            comment(new,'Column array example with single precision');
        case 1.2            
            time=transpose(linspace(-1,1,75));
            data=[time time.^2 time.^3];
            new=create(data,file,'uint16',time);     
            setType(new,1);
            comment(new,'Column array example with 16 bit scaling');
        case 1.3            
            time=transpose(linspace(-1,1,75));
            data=[time time.^2 time.^3];
            new=create(data,file,'uint8',time);     
            setType(new,1);
            comment(new,'Column array example with 8 bit scaling');
        case 2
            new=self(1,'demonstration2.taf');
            transpose(new);          
            comment(new,'Row array example');            
        case 3
            x=linspace(-3,+3,75);
            y=linspace(-4,+4,100);
            [X,Y]=ndgrid(x,y);
            data=exp(-(X.^2/2/0.25^2)-(Y.^2/2/0.5^2));            
            new=create(data,file);
            adjust(new,1,'span',[min(y(:)) max(y(:))]);
            adjust(new,2,'span',[min(x(:)) max(x(:))]);
            setType(new,3);
            comment(new,'Scaled image example');
        case 3.1
            x=linspace(-3,+3,75);
            y=linspace(-4,+4,100);
            [X,Y]=ndgrid(x,y);
            Y0=linspace(-2,2,3);
            L=numel(Y0);
            data=nan(numel(x),numel(y),L);
            for k=1:L
                data(:,:,k)=2*exp(-(X.^2/2/0.25^2)-((Y-Y0(k)).^2/2/0.5^2));
            end
            new=create(data,file);
            adjust(new,1,'span',[min(y(:)) max(y(:))]);
            adjust(new,2,'span',[min(x(:)) max(x(:))]);
            setType(new,3);
            comment(new,'Image stack example');
        otherwise
            error('ERROR: invalid example number');
    end
    if standard
        fprintf('done\n');
    end
    if n == 1
        object=repmat(new,size(example));
    else
        object(n)=new;
    end
end

if nargout() > 0
    varargout{1}=object;
end

end