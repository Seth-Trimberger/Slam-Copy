% createStartupFile Automatic startup file generation
%
% Running this function:
%    createStartupFile();
% will create a startup file for use with SLAM.  This file will be located
% in the folder specified by the userpath function.
% 
% If a startup file is already present, the necessary command will be
% displayed and copied to the clipboard.  The user is then prompted to
% press return so that file can be opened in the MATLAB editor and the new
% commaned pasted in an appropriate location.  Pressing any other key
% before return or Control-C cancels this process.
%
% See also userpath
%
function createStartupFile()

% create startup file
target=fileparts(fileparts(mfilename('fullpath')));
command=sprintf('addpath(''%s'');',target);

name='startup.m';
file=which(name);
if isempty(file)
    file=fullfile(userpath(),name);
    fid=fopen(file,'w');
    fprintf(fid,'function startup()\n\n');
    fprintf(fid,'%s\n',command);
    fprintf(fid,'\nend');
    fclose(fid);       
else
    fprintf('To access the SLAM toolbox, add :\n');
    fprintf('   %s\n',command);
    fprintf('in the existing startup file. This command has been copied\n');
    fprintf('to the clipboard.\n');
    clipboard('copy',command);
    commandwindow();
    response=input('Press return to edit the startup file ','s');    
    if isempty(response)
        edit(file);   
    end
end

end