% convertImage Convert image file(s) to TAF
%
% This *static* method converts an image file to *.taf file.
%    TAF.convertImage(file,format);
% The input "file" can be a character array or scalar string.  Optional
% input "format" controls how data is stored in the *.taf file, defaulting
% to settings used in the source image (typically 'uint8' or 'uint16'). The
% converted file retains same base name with a new extension, e.g.
% 'mydata.png' is converted to 'mydata.taf'.
%
% There are several ways to convert multiple files simultaneously.  When
% input "file" is empty/omitted, the user is interactively prompted to
% select one or more files.  Passing wildcard strings, such as '*.png', in
% the "file" argument also launches multiple conversions.
%
% See also TAF, imformats
%
function convertImage(file,format)

persistent filter
if isempty(filter)
    filter='';
    list=imformats();
    for m=1:numel(list)
        for n=1:numel(list(m).ext)
            ext=list(m).ext{n};
            filter=sprintf('%s;*.%s',filter,ext);
            filter=sprintf('%s;*.%s',filter,upper(ext));
        end
    end
    filter=filter(2:end);
    filter={filter 'Supported image formats'};
end

% manage input
Narg=nargin();
if (Narg < 1) || isempty(file)
    file=filter;
end
file=selectFiles(file);

if (Narg < 2) || isempty(format)
    format='';
end

% file conversion(s)
persistent create
if isempty(create)
    create=handy.generateCall('TAF.create');
end

for n=1:numel(file)
    [location,short,~,]=fileparts(file{n});
    new=fullfile(location,[short '.taf']);
    local=format;
    try
        if isempty(local)
            info=imfinfo(file{n});
            if strcmp(info.ColorType,'truecolor') ...
                    || any(info.BitDepth == [1 8])
                local='uint8';
            elseif info.BitDepth == 16
                local='uint16';
            else
                warning('Unable to determine image format--using single precision');
                local='single';
            end
        end        
        data=imread(file{n});
        create(data,new,local);
    catch ME
        throwAsCaller(ME);
    end
end   



end