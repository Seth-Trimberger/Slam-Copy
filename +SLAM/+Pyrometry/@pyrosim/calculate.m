% calculate Perform pyrometry calculations
%
% This method performs pyrometry calculations using current object
% properties.
%    [data,param]=calculate(object);
% Output "data" is a four-column array of source temperature, collected
% power, photon flux, and signal level.  Output "param" is a structure of
% calculation parameters derived from the current object properties.
% 
% See also pyrosim, configure, plot
%
function [data,param]=calculate(object)

% general parameters
c0=2.99792458e8; % vacuum speed of light [m/s]
h=4.135667516E-15; % Planks's constant [eV*s]
kB=8.6173324E-5; % Boltzman's constant [eV/K]
A=2/(h^3*c0^2); % [1/eV^3/m^2/s]
eV=1.602176487E-19; % electron volt [J]
%sigma=(2*kB^4*pi^5)/(15*c0^2*h^3)*eV; % [W/m^2 K^4]
%fprintf('sigma=%.9g\n',sigma);

% define wavelength domain
hc=h*c0;
min_energy=hc./(object.Range(2)*1e-6); % [eV]
max_energy=hc./(object.Range(1)*1e-6);
energy=linspace(min_energy,max_energy,object.Points);
wavelength=hc./energy*1e6; % [um]

emissivity=makecurve(object.Emissivity,wavelength);
relay=makecurve(object.Relay,wavelength);
diameter=object.Diameter/1e3; % convert mm to m
relay=(pi*diameter*sind(object.Angle)/2)^2*relay;
response=makecurve(object.Response,wavelength);

% perform calculation at each temperature
N=numel(object.Temperature);
data=nan(N,4);
data(:,1)=object.Temperature;
for n=1:N
    kT=kB*object.Temperature(n);
    radiance=zeros(size(energy));
    index=energy<(kT*1e-6);
    radiance(index)=kT*energy(index).^2;
    radiance(~index)=energy(~index).^3./(exp(energy(~index)/kT)-1);
    radiance=A*emissivity.*radiance;
    power=relay.*radiance;
    data(n,2)=eV*trapz(energy,power); % collected power in Watts
    data(n,3)=trapz(energy,power./energy); % photon flux in 1/seconds
    data(n,4)=eV*trapz(energy,power.*response); % electrical signal in volts
end

param=struct();
name={'Emissivity' 'Diameter' 'Angle' 'Relay' 'Response' 'Range' 'Points'};
for k=1:numel(name)
    param.(name{k})=object.(name{k});
end

end

function y=makecurve(inp,x)

if ischar(inp) % scan text file
    format='%g%g';
    fid=fopen(inp,'rt');
    Nheader=0;
    success=false;
    while ~feof(fid)
        temp=fgets(fid);
        [~,count]=sscanf(temp,format);
        if count==2
            success=true;
            break
        end
        Nheader=Nheader+1;
    end
    if success
        frewind(fid);
        for k=1:Nheader
            fgets(fid);
        end
        data=fscanf(fid,format,[2 inf]);
        data=transpose(data);
        fclose(fid);
    else
        fclose(fid);
        error('ERROR: unable to read data file %s',inp);
    end
    y=interp1(data(:,1),data(:,2),x,'pchip',0);
elseif isscalar(inp) % replicate value
    y=repmat(inp,size(x));
else % tabular data (columns)
    y=interp1(inp(:,1),inp(:,2),x,'pchip',0);
end

end