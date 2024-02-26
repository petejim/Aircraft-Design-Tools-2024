function [Cd0, Swet] = nacelleDrag(L, D, Cond, n)

%==========================================================================
% INPUTS
% l array of lengths of the equivalent bodies of revolution (in ft)
% d largest diameter of the fuselage (in ft)
% Cond flight conditions [alt(ft), KTAS]

% ASSUMES two conical ends with a cylindrical center shape
%==========================================================================

if n == 0
    Cd0 = 0;
    Swet = 0;
    return
end

[Tstd, ~, rho, ~] = standatm(Cond(1), 0, "IMP");

T = Tstd*1.8;

f = sum(L)/D;

FF = 1 + (0.35/f);

x0 = 0.374*sum(L) + 0.533*L(1); %ft

mu = 3.17*10^(-11)*T^1.5*(734.7/(T+216)); %lb*s/ft^2

ReF = (rho*Cond(2)*1.688*sum(L))/mu;

k = 30*10^-6*3.281; %ft

ReC = 38.21*(sum(L)/k)^1.053;

if ReF > ReC
    Re = ReC;
else
    Re = ReF;
end

xtr = (((x0/sum(L))*(1/Re)^-0.375)/36.9)^(1/0.625); %ft

Cf = (0.074/Re^0.2)*(1-((xtr-x0)/sum(L)))^0.8;

Swet = pi*D/4*((2*sqrt(L(3)^2+D^2/4))-D+4*L(2)+2*sqrt(L(3)^2+D^2/4));

Scom(1) = pi*D/2*sqrt(L(3)^2+D^2/4);
Scom(2) = pi*D*L(2);
Scom(3) = pi*D/2*sqrt(L(3)^2+D^2/4);

Cd0A = (Cf*FF*Scom(1))/Swet;
Cd0B = (Cf*Scom(2))/Swet;
Cd0C = (Cf*FF*Scom(3))/Swet;

Cd0 = Cd0A+Cd0B+Cd0C;