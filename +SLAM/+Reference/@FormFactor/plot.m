% UNDER CONSTRUCTION
%
%
% See also FormFactor
%
function plot(object)

figure('WindowStyle','normal');
yyaxis left
plot(object.Data(:,1),object.Data(:,2));
xlabel('Photon energy (eV)');
ylabel('Real form factor');
set(gca,'XScale','log');
title(object.Name);
yb=max(object.Data(:,2))*1.05;
ylim([-yb +yb]);

yyaxis right
plot(object.Data(:,1),object.Data(:,3));
ylabel('Imaginary form factor');

end