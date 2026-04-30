%[text] The pyrosim class calculates the power collected from an emitting source at various temperatures.
%[text] $\\Phi = \\int d\\lambda \\int \\sin \\theta \\cos \\theta\\ d\\theta \\int d\\phi  \\frac{dL}{d\\lambda}  \\approx \\left( \\frac{\\pi d \\sin \\theta}{2} \\right)^2 \\int\_{\\lambda\_1}^{\\lambda\_2} \\frac{\\epsilon\\ \\eta\\  c\_1}{\\lambda^5 \\left(e^{c\_2/\\lambda T}-1\\right)}\\ d\\lambda$
import SLAM.Pyrometry.pyrosim
obj=pyrosim();
plot(obj);
%%
%[text] Customization
obj.Diameter=0.2;
obj.Angle=asind(0.2);
obj.Temperature=500:500:2000;
plot(obj);
%%
configure(obj);

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
