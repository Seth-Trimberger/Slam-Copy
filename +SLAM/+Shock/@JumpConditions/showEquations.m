% showEquations Show jump conditions
%
% This *static* method displays the jump condition equations in the MATLAB
% HTML viewer.  It can be called directly or through an existing object.
%    JumpConditions.showEquations();
%    object=JumpConditions();
%    object.showEquations();
%
% See also JumpConditions
%
function showEquations(varargin)

location=fileparts(mfilename('fullpath'));
source=fullfile(location,'ref','equations.m');
start=pwd();
CU=onCleanup(@() cd(start));

location=tempdir();
duplicate=fullfile(location,'equations.m');
copyfile(source,duplicate);
cd(location);
publish(duplicate,'outputDir',pwd);
open(fullfile(location,'equations.html'));

end