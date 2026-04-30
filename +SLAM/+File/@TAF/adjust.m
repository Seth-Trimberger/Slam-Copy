% adjust Adjust implicit grid
%
% This method adjusts one implicit grid in an array file.
%   adjust(object,dimension,operation,value);
% The input "dimension" must be an integer consistent with the number of
% array dimensions. The input "operation" can be any of the following.
%    -'shift' adds input "value" to the implicit grid.
%    -'scale' multiples the implicit grid by input "value".
%    -'start' replaces the first value of the implicit grid by "value".
%    -'step' replaces the implicit grid spacing by "value".
%    -'span' makes the implicit grid cover the "value" range [min max].
%
% Object arrays can be adjusted simultaneously, apply the same changes
% across multiple files.
%
% See also TAF
%
function adjust(object,varargin)

% manage object arrays
if ~isscalar(object)
    for n=1:numel(object,varargin{:})
        adjust(object(n),varargin{:})
    end
    return
end

% verify file
try
    info=object.Info;
catch ME
    throwAsCaller(ME);
end

% manage input
Narg=nargin()-1;
assert(Narg == 3,'ERROR: invalid number of inputs');

dimension=varargin{1};
valid=1:info.Dimensions;
assert(any(dimension == valid),'ERROR: invalid array dimension');

operation=varargin{2};
assert(ischar(operation) || isStringScalar(operation),...
    'ERROR: invalid operation request');
operation=lower(operation);

value=varargin{3};
switch operation
    case {'start' 'step' 'shift' 'scale'}
        assert(isnumeric(value) && isscalar(value) ...
            && isreal(value) && isfinite(value),...
            'ERROR: invalid %s value',operation);
        if any(strcmp(operation,{'step' 'scale'}))
            assert(value > 0,...
                'ERROR: %s value must be greater than zero',operation);
        end
    case 'span'
        assert(isnumeric(value) && isreal(value) ...
            && all(isfinite(value)) && (numel(value) == 2),...
            'ERROR: invalid grid bound');
        assert(diff(value) > 0,...
            'ERROR: %s bound must have nonzero width',operation);
    otherwise
        error('ERROR: "%s" is not a valid file adjustment',operation);
end

% determine byte offsets
offset=1024+4*8; % skip bits, intercept, slope, number dimensions
for k=1:(dimension-1)
    offset=offset+3*8; % dimension size, start, step
end
StartOffset=offset+8; % skip dimension size
StepOffset=StartOffset+8;
start=info.Start(dimension);
step=info.Step(dimension);

% perform operation
fid=fopen(object.Target,'r+','ieee-le');
switch operation
    case 'start'
        fseek(fid,StartOffset,'bof');
        fwrite(fid,value,'double');
    case 'step'
        fseek(fid,StepOffset,'bof');
        fwrite(fid,value,'double');
    case 'shift'
        fseek(fid,StartOffset,'bof');
        fwrite(fid,start+value,'double');
    case 'scale'
        fseek(fid,StartOffset,'bof');
        fwrite(fid,start*value,'double');
        fwrite(fid,step*value,'double');
    case 'span'
        fseek(fid,StartOffset,'bof');
        fwrite(fid,value(1),'double');
        N=info.Size(dimension);
        step=(value(2)-value(1))/(N-1);
        fwrite(fid,step,'double');
end
fclose(fid);
object.PreviousInfo=[];

end