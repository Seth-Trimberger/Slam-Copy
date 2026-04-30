% UNDER CONSTRUCTION
% getData Extract data from existing curve
%
%
%
% See also SLAM.Graphics
%
function [x,y]=getData(target)

% manage input
Narg=nargin();
if (Narg < 1) || isempty(target)
    target=gco();
end

try
    x=get(target,'XData');
    y=get(target,'YData');
    return   
end

end