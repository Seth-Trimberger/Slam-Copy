% UNDER CONSTRUCTION
%
% See also JumpConditions
%
function showExample(varargin)

object=SLAM.Shock.JumpConditions();
object.InitialDensity=8.923;

%
fprintf('First [up Us] point on page 58: ');
in=[0.483 4.599]; 
fprintf('%.3f %.3f\n',in);
out=calculate_V_P(object,in);
fprintf('\tCalculated [V P]: %.4f %.3f\n',out);
fprintf('\tPublished  [V P]: %.4f %.3f\n',[0.1003 19.821]);

% 
fprintf('Last [V P] point on page 59: ');
in=[0.0786 139.704];
fprintf('%.4f %.3f\n',in);
out=calculate_up_Us(object,in);
fprintf('\tCalculated [up Us]: %.3f %.3f\n',out);
fprintf('\tPublished  [up Us]: %.3f %.3f\n',[2.161 7.241]);

end