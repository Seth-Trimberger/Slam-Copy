% showExample Show Kerley example #1
%
% This *static* method shows the first example in Kerley's technical
% report.  The command:
%    kinterp1.showExample1();
% creates a new figure window contrasting rational interpolation with other
% standard methods.
%
% See also kinterp1
%
function varargout=showExample1()

x=1:5;
y=[0 0 0 1 2];
xi=linspace(min(x),max(x),1000);

yi1=interp1(x,y,xi,'spline');
yi2=interp1(x,y,xi,'cubic');
yi3=interp1(x,y,xi,'makima');

figure();
plot(x,y,'ko',xi,yi1,xi,yi2,xi,yi3);

object=SLAM.Sesame.kinterp1(x,y);
yi4=evaluate(object,xi);
line(xi,yi4,'Color','k');

xlabel('x');
ylabel('y');
legend('Data','Splne','Cubic','Makima','Kerley','Location','northwest');
title('Kerley example #1');

if nargout() > 0
    varargout{1}=object;
end

end