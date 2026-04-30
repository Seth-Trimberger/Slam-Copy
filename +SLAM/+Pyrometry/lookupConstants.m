% lookupConstants
%
% This function looks up constants associated with optical pyrometry.
%    value=lookupConstants();
% The output "value" is a numeric array with three elements.
%    -The first element contains c1=2*h*c0^2 in units of W*nm^4/mm^2*sr.
%    When used in the Planck equation, it yields spectral radiance in
%    W/mm^2*sr/nm.
%    -The second element contains c2=h*c0/kB in units of nm*K.
%    -The third element contains c3=xmax*T, where xmax is the wavelength of
%    peak black body emission (Wien's displacement law), in units of nm*K.
%
% Calling this function with no output:
%    lookupConstants();
% prints the above constants in the command window.
%
% See also SLAM.Pyrometry, SLAM.Reference.CODATA
% 
function varargout=lookupConstants()

% CODATA lookup
persistent c1 c2 c3
if isempty(c1)
    report=SLAM.Reference.CODATA('$Planck constant');
    h=report.Value;
    report=SLAM.Reference.CODATA('speed of light');
    c0=report.Value;
    report=SLAM.Reference.CODATA('$Boltzmann constant');
    kB=report.Value;
    c1=2*h*c0^2; % W*m^2/sr
    c1=c1*(1e9)^4/(1e3)^2;  % W*nm^4/mm^2*sr
    c2=h*c0/kB; % m*K
    c2=c2*1e9; % nm*K
    z=@(x) 1-exp(-x)-x/5;
    options=optimset('TolX',1e-9);
    x=fzero(z,[4 6],options);
    c3=c2/x; % nm*K
end

value=[c1 c2 c3];
units={'W*nm^4/mm^2*sr' 'nm*K' 'nm*K'};

% manage output
if nargout() > 0
    varargout{1}=value;
    varargout{2}=units;
    return
end
fprintf('Blackbody constants\n');
for n=1:numel(value)
    fprintf('   c%d = %#.9g %s\n',n,value(n),units{n});
end

end