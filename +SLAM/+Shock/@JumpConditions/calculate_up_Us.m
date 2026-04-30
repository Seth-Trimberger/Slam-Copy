% calculate_up_Us Calculate particle and shock velocity
%
% This methods calculates particle and shock velocity behind a shock from
% the corresponding pressure and specific volume.
%    out=calculate_up_Us(object,in);
% The input "in" must be a two-column array of [V P] values.  The output
% "out" is a two-column array of [up Us] values with the same number of rows
% as "in".
%
% See also JumpConditions
%
function out=calculate_up_Us(object,in)

assert(isnumeric(in) && ismatrix(in) && (size(in,2) == 2),...
    'ERROR: invalid input array');

V=in(:,1);
P=in(:,2);

V0=1/object.InitialDensity;
P0=object.InitialPressure;

up=sqrt((P-P0).*(V0-V));
Us=V0*sqrt((P-P0)./(V0-V));

out=[up Us];

end