% showExample2 Show Kerley example #2
%
% This *static* method shows the second example in Kerley's technical
% report.  The command:
%    kinterp1.showExample2();
% creates a new figure window showing rational interpolation behavior with
% two slightly different meshes.  This comparison highlights the
% importance of mesh selection.
%
% See also kinterp1
%
function varargout=showExample2()

xi=linspace(0,1.2,1000);

x1=[0 0.2 0.4 0.5 0.65 0.8 0.9 1.0];
y1=curve(x1);

object1=SLAM.Sesame.kinterp1(x1,y1);
yi1=evaluate(object1,xi);

x2=[0 0.2 0.4 0.55 0.75 0.9 1.0];
y2=curve(x2);
object2=SLAM.Sesame.kinterp1(x2,y2);
yi2=evaluate(object2,xi);

figure();
plot(x1,y1,'ko',xi,yi1,'k',x2,y2,'kx',xi,yi2,'k--');
xlabel('x');
ylabel('y');
title('Kerley example #2');

if nargout() > 0
    varargout{1}=object1;
    varargout{2}=object2;
end

end

function y=curve(x)
y=nan(size(x));
k=(x <= 0.5);
y(k)=2.9154519*x(k).^3;
k=(x > 0.5) & (x <= 0.8);
y(k)=0.36443149;
k=(x > 0.8);
y(k)=2.9154519*(x(k)-0.3).^3;

end