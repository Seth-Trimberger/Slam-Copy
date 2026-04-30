% slamroot SLAM root folder
%
% This function returns the absolute location of the SLAM folder:
%    s=slamroot();
% or prints this information in the command window.
%    slamroot();
%
% Adding an input argument:
%    slamroot('copy');
% copies the folder to the system clipboard.
% 
function varargout=slamroot(mode)

% determine root folder
location=mfilename('fullpath');
location=fileparts(location);

% manage input
show=true();
if nargin() > 0
   assert(ischar(mode) || isStringScalar(mode),'ERROR: invalid mode');   
   switch lower(mode)
       case 'copy'
           clipboard('copy',location);
           fprintf('Root folder copied to system clipboard\n');
       otherwise
           error('ERROR: unsupported mode');
   end
   show=false();
end

% manage output
if nargout() > 0
    varargout{1}=location;
elseif show
    fprintf('Root folder is "%s"\n',location);
end
return

end