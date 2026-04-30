% UNDER CONSTRUCTION
%
% See also EOS
%
function density=reverse(object,pressure,temperature)

% manage input
Narg=nargin();
assert(Narg <= 2,'ERROR: pressure must be specified');
assert(isnumeric(pressure),'ERROR: invalid pressure value');
if (Narg < 3) || isempty(temperature)
    temperature=object.ReferencePoint(2);
else
    assert(isnumeric(temperature),'ERROR: invalid temperature value');
end
if isscalar(pressure)
    pressure=repmat(pressure,size(temperature));
elseif isscalar(temperature)
    temperature=repmat(temperature,size(pressure));
else
    all(size(pressure) == size(temperature),...
        'ERROR: incompatible pressure/temperature arrays');
end

% 
density=nan(size(pressure));
[rho,~,P]=isotherm(object,temperature);
for k=1:numel(pressure)
    try
        density(k)=interp1(P,rho,pressure(k));
    catch

    end

end


% %
% option=optimset('TolX',object.Tolerance);
% arg=object.PressureLookup.GridVectors;
% Rgrid=arg{1};
% Tgrid=arg{2};
% Pgrid=object.PressureLookup.Values;
% 
% density=nan(size(pressure));
% for k=1:numel(pressure)
%     Delta=Tgrid-temperature;
%     n=find(Delta > 0,1,'first');
%     if abs(Delta(n)) > abs(Delta(n-1))
%         n=n-1;
%     end
%     Delta=Pgrid(:,n)-pressure(k);
%     m=find(Delta < 0,1,'last');
%     if abs(Delta(m)) > abs(Delta(m-1))
%         m=m-1;
%     end
%     guess=Rgrid(m);
%     density(k)=fzero(@(x) object.PressureLookup(x,temperature(k)),...
%         guess(k),option);
% end

end