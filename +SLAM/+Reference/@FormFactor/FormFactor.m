% Form factor class
%
% This class supports atomic form factor calculations.  Objects may be
% created from an element symbol:
%    object=FormFactor(symbol); 
% or manually.
%    object=FormFactor(data,rhoA,MW);
% The latter expects a three-column array [energy f1 f2], an atomic
% density, and a molecular weight build a custom object.  The former
% generates this information using standard atomic symbols: 'Fe' for iron,
% 'Cu' for copper, and so forth.
%
%
classdef FormFactor
    %%
    properties
        Name = 'unknown'
    end
    methods
        function object=set.Name(object,value)
            assert(ischar(value) || isStringScalar(value),...
                'ERROR: invalid name');
            object.Name=value;
        end     
    end
    %%
    properties (SetAccess=protected)
        Data            % Data Form factor array [Energy f1 f2]
        AtomicDensity   % AtomicDensity Atoms per cubic meter
        AtomicMass      % AtomicMass Grams per mole of substance
    end
    methods
        function object=FormFactor(data,rhoA,MW)
            persistent NA
            if isempty(NA)
                info=SLAM.Reference.CODATA('avogadro');
                NA=info.Value;
            end
            if nargin == 1
                symbol=data;
                try
                    object.Data=lookupElement(symbol);
                catch ME
                    throwAsCaller(ME)
                end                
                symbol=lower(symbol);
                symbol(1)=upper(symbol(1));
                object.Name=symbol;
                info=SLAM.Reference.PeriodicTable(symbol);
                object.AtomicMass=info.Mass;
                rho=info.StandardDensity; % g/cc              
                if strcmpi(info.StandardPhase,'gas')
                    rho=rho/1e3; % gas density stored as g/L
                end
                rho=rho*1e6; % convert to g/m^3
                object.AtomicDensity=rho*NA/object.AtomicMass;
            else
                assert(isnumeric(data) && ismatrix(data) && (size(data,2) == 3),...
                    'ERROR: invalid data array');
                object.Data=data;
                assert(isnumeric(rhoA) && isscalar(rhoA) && (rhoA > 0),...
                    'ERROR: invalid atomic density');                
                object.AtomicDensity=rhoA;
                assert(isnumeric(MW) && isscalar(MW),...
                    'ERROR: invalid atomic mass');
                if isfinite(MW)
                    assert(MW > 0,'ERROR: invalid atomic mass')
                    object.AtomicMass=MW;
                else
                    object.AtomicMass=nan;
                end
            end           
        end
    end    
end

function data=lookupElement(symbol)

% verify element symbol
symbol=lower(symbol);
location=fileparts(mfilename('fullpath'));
file=fullfile(location,'CXRO',[symbol '.nff']);
assert(isfile(file),'ERROR: unrecognized element');

% read element file
fid=fopen(file,'r');
fgetl(fid); % skip header line
data=fscanf(fid,'%g %g %g',[3 inf]);
fclose(fid);

data=transpose(data);

end