% export Export material to separate file
%
% This method exports one material to a separate text file.
%    export(object,material);
% Mandatory input "material" indicates the (integer) material number.  This
% number is used for the exported file name, e.g.:
%    export(object,3334);
% write/overwrites the file '3334.ascii2' with material data from the
% Sesame file.
%
% See also File, query, search
%
function export(object,material)

% manage input
Narg=nargin();
assert((Narg > 1) && isscalar(material) && ...
    isnumeric(material),'ERROR: invalid material number')

% read material data
try
    [~,data]=query(object,material);    
catch ME
    throwAsCaller(ME);
end

start=+inf;
stop=-inf;
for n=1:numel(data.Table)
    start=min(start,data.Table(n).Start);
    stop=max(stop,data.Table(n).Stop);
end
bytes=stop-start+1;

in=fopen(fullfile(object.Location,object.Name),'r');
fseek(in,start,'bof');
buffer=fread(in,bytes,'uint8');
fclose(in);

% write material data
file=sprintf('%d.ascii2',material);
out=fopen(file,'w');
fprintf(out,'Version 2.0\n');
fwrite(out,buffer,'char');
fclose(out);

end