% UNDER CONSTRUCTION
%
% See also FormFactor
%
function varargout=calculateIndex(object)

energy=object.Data(:,1);

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
index=1+r0*lambda.^2*object.AtomicDensity./(2*pi).*(...
    -object.Data(:,2)+1i*object.Data(:,3));

% manage output
if nargout > 0
    varargout{1}=[energy real(index) imag(index)];
    return
end

figure('WindowStyle','normal');
yyaxis left
plot(energy,real(index));
xlabel('Photon energy (eV)');
ylabel('Real index');
set(gca,'XScale','log');
title(object.Name);
yb=max(real(index))*1.05;
ylim([0 +yb]);

yyaxis right
plot(energy,imag(index));
ylabel('Imaginary index');

end