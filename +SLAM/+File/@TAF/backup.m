% backup Backup file(s)
%
% This method creates a backup copy of the file in a new subfolder.
%    backup(object);
% The files referenced by each element of "object' is copied to a folder
% "backup_yyyymmdd_HHMMSS" where the year (yyyy), month (mm), day (dd),
% hour (HH), minute (MM), and (SS) indicate when the backup was made.  That
% character array is returned as an output by request.
%     folder=backup(object);
%
% NOTE: backup time stamps are only accurate to the second level.  Rapid, 
% sequential calls to this method may overwrite existing backup files.
% Caution is needed when this method is used inside a loop.
%
% See also TAF
% 
function varargout=backup(object)

stamp=datevec(datetime('now'));
stamp=round(stamp);
stamp=sprintf('backup_%04d%02d%02d_%02d%02d%02d',stamp);
mkdir(stamp);


for n=1:numel(object)
    source=object(n).Target;
    target=fullfile(stamp,object(n).Name);
    copyfile(source,target,'f');
end

% manage output
if narogut() > 0
    varargout{1}=stamp;
end

end