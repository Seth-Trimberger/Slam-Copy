%% Jump conditions
% 
% Jump conditions link states ahead/behind a shock front via mass and
% momentum conservation.  Four sets of material variables are considered
% here.
% 
% * Particle velocity $u_p$ of material behind the shock front relative to
% material ahead of the shock front.
% * Shock velocity $U_s$ relative to material ahead of the shock front.
% * Pressures (technically longitudinal stresses) $P_0$ ahead and $P$
% behind the shock front.
% * Specific volumes $V_0$ ahead and $V$ behind the shock front.  These
% values are the inverse of specific density $\rho$.
% 

%% 
% *Standard jump conditions*
%
% $\frac{V}{V_0} = \frac{U_s-u_p}{U_s}$ 
%
% $P-P_0 = \rho_0 U_s u_p$ 
%

%% 
% *Working backwards*
%
% $u_p^2 = (P-P_0) (V_0 - V)$
%
% $U_S^2 = V_0^2 \left( \frac{P-P_0} {V_0 - V)} \right)$