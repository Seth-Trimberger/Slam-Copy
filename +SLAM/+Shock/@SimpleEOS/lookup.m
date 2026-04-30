% UNDER CONSTRUCTION
function b=lookup(object,quantity,temperature,volume)

T0=object.Parameters(1);
param=object.Parameters(2:end);
v0=1/param(1);


% manage input
switch nargin()
    case 2
    case 4
    otherwise
        error('ERROR: invalid lookup request');
end

end