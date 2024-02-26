function [Cd0, Sref] = fuselageDrag(L, D, Cond, eng, t_upsweep)

%==========================================================================
% INPUTS
% l array of lengths of the equivalent bodies of revolution (in ft)
% d largest diameter of the fuselage (in ft)
% Cond flight conditions [alt(ft), KTAS]

% FOR eng == 1 (Two+ engines) ASSUMES two parabolic ends with a cylindrical center shape
% FOR eng == 0 (One engine) ASSUMES a parabolic & a conical end with a cylindrical center shape
%==========================================================================

% standard atmospheric conditons from input flight altitude and speed
[Tstd, ~, rho, ~] = standatm(Cond(1), 0, "IMP");

% kelvin to rankine
T = Tstd*1.8; % R

% fuselage fineness ratio
f = sum(L)/D; 

% fuselage form factor - Hoerner's method
FF = 1 + (60/f^3) + (f/400); 

% location of start of turbulent boundary layer - relation from Iscold's
% instructure
x0 = 0.374*sum(L) + 0.533*L(1); % ft

% viscosity - equation from gudmundsson
mu = 3.17*10^(-11)*T^1.5*(734.7/(T+216)); %lb*s/ft^2

% reynolds number from flight conditions
ReF = (rho*Cond(2)*1.688*sum(L))/mu;

% skin roughness factor - for high quality paint from Iscold's instructure
k = 30*10^-6*3.281; %ft

% cutoff reynolds number based on skin roughness
ReC = 38.21*(sum(L)/k)^1.053;

% compare reynolds number, use lower one
if ReF > ReC
    Re = ReC;
else
    Re = ReF;
end

% location of laminar-turbulent transition - from gudmundsson
xtr = (((x0/sum(L))/(1/Re)^(0.375))/36.9)^(1/0.625); %ft

% skin friction coeff. for mixed laminar-turbulent flow - gudmundsson
Cf = (0.074/Re^0.2)*(1-((xtr-x0)/sum(L)))^0.8;

% calculate wetted areas
% for two engines
if eng == 2
Sref = pi*D/4*(1/(3*L(1)^2)*((4*L(1)^2+D^2/4)^1.5-D^3/8)-D+4*L(2)+2*1/(3*L(1)^2)*((4*L(1)^2+D^2/4)^1.5-D^3/8));
Swet = (4/3)*L(1)*D + L(2)*D + (4/3)*L(3)*D;

Scom(1) = pi*D/(12*L(1)^2)*((4*L(1)^2+D^2/4)^1.5-D^3/8)-pi*D^2/4; % parabaloid
Scom(2) = pi*D*L(2); % cylinder
Scom(3) = pi*D/(12*L(3)^2)*((4*L(3)^2+D^2/4)^1.5-D^3/8)-pi*D^2/4; % parabaloid

% if one engine
elseif eng == 1
Sref = pi*D/4*(1/(3*L(1)^2)*((4*L(1)^2+D^2/4)^1.5-D^3/8)-D+4*L(2)+2*sqrt(L(3)^2+D^2/4));
Swet = (4/3)*L(1)*D + L(2)*D + (1/3)*L(3)*D;

Scom(1) = pi*D/(12*L(1)^2)*((4*L(1)^2+D^2/4)^1.5-D^3/8)-pi*D^2/4; % parabaloid
Scom(2) = pi*D*L(2); % cylinder
Scom(3) = pi*D/2*sqrt(L(3)^2+D^2/4); % cone

else
    error('Input proper engine flag: two+ engines == 2, one engine == 1')
end

% tail upsweep angle drag 

% equation fit from graph data on iscold's instructure
K = @(t_upsweep) (0.019251*(t_upsweep^3)) - (0.0024779*(t_upsweep^2)) + (0.0189825*t_upsweep) - 0.4070;

% upsweep factor at tail upsweep angle in degrees
K_fuse = K(t_upsweep);


% drag on components of fuselage
Cd0A = (Cf*FF*Scom(1))/Swet; % nose section
Cd0B = (Cf*Scom(2))/Swet; % center section
Cd0C = (Cf*FF*Scom(3))/Swet; % tail section

Cd0_up = (K_fuse / 100) * Cd0C; % additional drag from tail upsweep

% add all fuselage components to get total parasitic drag
Cd0 = Cd0A + Cd0B + Cd0C + Cd0_up; 