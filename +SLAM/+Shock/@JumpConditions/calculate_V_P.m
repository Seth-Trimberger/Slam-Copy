% calculate_V_P Calculate volume and pressure
%
% This methods calculates specific volume and pressure behind a shock from
% the corresponding particle and shock velocity.
%    out=calculate_V_P(object,in);
% The input "in" must be a two-column array of [up Us] values.  The output
% "out" is a two-column array of [V P] values with the same number of rows
% as "in".
%
% See also JumpConditions
%
function out=calculate_V_P(object,in)

assert(isnumeric(in) && ismatrix(in) && (size(in,2) == 2),...
    'ERROR: invalid input array');

up=in(:,1);
Us=in(:,2);

rho0=object.InitialDensity;
P0=object.InitialPressure;

V=(1-up./Us)/rho0;
P=P0+rho0*Us.*up;

out=[V P];

end