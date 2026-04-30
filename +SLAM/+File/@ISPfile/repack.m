% repack Reduce file size
%
% This method reduces ISP file size by eliminating overwritten data.
%    repack(object);
%
% NOTE: size reduction only occurs in files where records have been
% overwritten, renamed, or revised.
%
% See also ISPfile
%
function repack(object)

report=probe(object);
if isempty(report)
    warning('ISP:EmptyRepack','File is empty--nothing to repack\n');
    return
end

file=fullfile(tempdir(),object.Name);
if isfile(file)
    delete(file);
end

new=SLAM.File.ISPfile(file);
for n=1:numel(report)
    temp=read(object,report(n).Name);
    write(new,temp,report(n).Name);
end

movefile(file,object.File,'f');

end