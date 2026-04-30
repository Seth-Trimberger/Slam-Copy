% showExample3 Show Kerley example #3
%
% This *static* method shows the third example in Kerley's technical
% report.  The command:
%    kinterp1.showExample3();
% prints a table of pressure interpolations in the command window.  The
% first two columns display true values of the underlying data set.  Each
% column thereafter show interpolations based on an exponential mesh of
% that dataset.  Column 3 contains the rational interpolation result.
% Columns 4-6 are based on MATLAB's interp1 function, which are presumably
% different than the implementations used in Kerley's report.
%
% NOTE: Kerley did not explicitly specify precision in the rational
% function algorithm code provided in Appendix A.  It is likely that the
% implicit typing of FORTRAN compilers at the time used single precision,
% whereas MATLAB defaults to double precision.  It is *possible* that the
% the deviation on the second to last entry (205.96 versus 205.90) is a
% related to this differnce.  The published table might also have a
% typographical error.
%
% See also kinterp1
%
function varargout=showExample3()

eta=[1 1.01372 1.04189 1.12060 1.31065 1.69626 2.38651 3.55549...
    5.51261 8.81618 14.4799 24.3631];
pressure=[0 0.01 0.0316228 0.1 0.316228 1 3.16228 10 31.6228...
    100 316.228 1000];

x=[1.007 1.03 1.08 1.22 1.50 1.87 2.04 2.2 3.0 4.0 4.25 4.5 4.75...
    5.0 7.20 12 20];
y=[0.0050581 0.022313 0.063243 0.20380 0.60892 1.4253 1.91969 2.4505...
    6.2221 13.750 16.151 18.768 21.603 24.658 61.38 205.9 650.07];
x=x(:);
y=y(:);

object=SLAM.Sesame.kinterp1(eta,pressure);
y1=evaluate(object,x);

y2=interp1(eta,pressure,x,'spline');
%y3=interp1(eta,pressure,x,'cubic');
y3=interp1(eta,pressure,x,'makima');

data=[x y y1 y2 y3];
fprintf('%10s%12s%12s%12s%12s\n',...
    'eta','P','Rational','Spline','Makima');
fprintf('%#10.4g%#12.5g%#12.5g%#12.5g%#12.5g\n',transpose(data));

if nargout() > 0
    varargout{1}=object;
end

end