% UNDER CONSTRUCTION
%
% See also FormFactor
%
%
function varargout=calculateAbsorbance(object)

energy=object.Data(:,1);
f2=object.Data(:,3);

persistent r0 hc
if isempty(r0)
    info=SLAM.Reference.CODATA('electron radius');
    r0=info.Value; % m
    info=SLAM.Reference.CODATA('planck constant',...
        '*molar','*reduced','*in');
    h=info.Value;
    info=SLAM.Reference.CODATA('speed');
    c=info.Value;
    info=SLAM.Reference.CODATA('elementary charge','*over');
    e=info.Value;
    hc=h*c/e; % eV*m
end

lambda=hc./energy;
mu=2*r0*lambda.*object.AtomicDensity.*f2;
penetration=1./mu;

% manage output
if nargout > 0
    varargout{1}=[energy mu penetration];
    return
end

figure('WindowStyle','normal');

yyaxis left
plot(energy,mu);
xlabel('Photon energy (eV)');
ylabel('Absorbance (1/m)`');
set(gca,'XScale','log','YScale','log');
title(object.Name);

yyaxis right
plot(energy,penetration);
ylabel('Penetration depth (m)');
set(gca,'YScale','log');

end