% setType Set array type code
%
% This method sets the array type code.
%    setType(object,code);
% Optional input "code" must be an integer from 0 to 255, defaulting to 0
% when this input is empty or omitted.  Defined type codes include:
%     -0 for generic arrays (any size/shape).  This is the default case.
%     -1 for column arrays (two dimensions).
%     -2 for row arrays (two dimensions).
%     -3 for images (two or three dimensions).  Three-dimensional arrays
%     typically represent a stack of scaled images, i.e. each layer is a
%     two-dimensional dataset.  RGB images can also be stored so long as
%     the array's third dimension length is a factor of three.
%
% NOTE: this method is meant for advanced users only.  Although basic
% consistency checks are performed and array itself remains unaltered,
% modifying the type code could alter interpretation of that data.
%
% See also TAF
%
function setType(object,code)

% manage input
Narg=nargin();
if (Narg < 2) || isempty(code)
    code=0;
else
    assert(isnumeric(code) && isscalar(code) && any(code == 0:255),...
        'ERROR: type code must be an integer from 0 to 255');   
end

% manage object arrays
if ~isscalar(object)
    for n=1:numel(object)
        setType(object(n),code);
    end
    return
end

% verify file
try
    info=object.Info;
catch ME
    throwAsCaller(ME);
end

switch code
    case 0
        % nothing to do
    case 1
        assert(info.Dimensions == 2,...
            'ERROR: data not consistent with column array');
    case 2
        assert(info.Dimensions == 2,...
            'ERROR: data not consistent with row array');
    case 3
        assert(any(info.Dimensions == [2 3]),...
            'ERROR: data not consistent with an image');
    otherwise
        error('ERROR: type code %d is not currently supported',code);
end

% update file code
fid=fopen(object.Target,'r+');
fseek(fid,6,'bof');
fwrite(fid,code,'uint8');
fclose(fid);
object.PreviousInfo=[];

end