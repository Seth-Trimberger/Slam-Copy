% convertText Convert text file(s) to TAF
%
% This *static* method converts a text file to *.taf file.
%    TAF.convertText(file,format);
% The input "file" can be a character array or scalar string.  Optional
% input "format" controls how data is stored in the *.taf file, defaulting
% to 'single'.  The converted file retains same base name with a new
% extension, e.g. 'mydata.txt' is converted to 'mydata.taf'
%
% There are several ways to convert multiple files simultaneously.  When
% input "file" is empty/omitted, the user is interactively prompted to
% select one or more files.  Passing wildcard strings, such as '*.txt', in
% the "file" argument also launches multiple conversions.
%
% NOTE: implicit grid settings are not updated by this method.  For
% example, the first column of the file is not interpreted as a uniformly
% sampled time base (even if it might be) but is stored explicitly.
% 
% See also TAF, File.readText
%
function convertText(file,format)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(file)
    file={'*.*' 'All files'};
end
file=selectFiles(file);

if (Narg < 2) || isempty(format)
    format='single';
end

% file conversion(s)
persistent create
if isempty(create)
    create=handy.generateCall('TAF.create');
end

for n=1:numel(file)
    [location,short,~,]=fileparts(file{n});
    new=fullfile(location,[short '.taf']);
    try
        data=SLAM.File.readText(file{n});
        create(data,new,format);
    catch ME
        throwAsCaller(ME);
    end
end   

end