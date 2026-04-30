% convertTektronix Convert Tektronix binary file(s) to TAF
%
% This *static* method converts a Tektronix binary file to *.taf file.
%    TAF.convertText(file,format);
% The input "file" can be a character array or scalar string.  Optional
% input "format" controls how data is stored in the *.taf file, defaulting
% to 'uint16'.  The converted file retains same base name with a new
% extension, e.g. 'mydata.wfm' is converted to 'mydata.taf'
%
% There are several ways to convert multiple files simultaneously.  When
% input "file" is empty/omitted, the user is interactively prompted to
% select one or more files.  Passing wildcard strings, such as '*.wfm', in
% the "file" argument also launches multiple conversions.
% 
% See also TAF, File.readText
%
function convertTektronix(file,format)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(file)
    file={'*.isf;*.ISF;*.wfm;*.WFM' 'Tektronix binary files'};
end
file=selectFiles(file);

if (Narg < 2) || isempty(format)
    format='uint16';
end

% file conversion(s)
persistent create
if isempty(create)
    create=handy.generateCall('TAF.create');
end

for n=1:numel(file)
    [location,short,ext]=fileparts(file{n});
    new=fullfile(location,[short '.taf']);
    fprintf('Converting %s to %s...',[short ext],[short '.taf']);
    try
        [data,time]=SLAM.File.readTektronix(file{n});
        create(data,new,format,time);
    catch ME
        throwAsCaller(ME);
    end
    fprintf('done\n');
end   

end