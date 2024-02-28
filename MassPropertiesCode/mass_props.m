% MASS PROPERTIES
function [weights, CG] = mass_props(inputs, config, coords)
% INPUTS:
%   inputs - vector of all necessary inputs (in order):
%   1   Sw - wing area                                              [ft^2]
%   2   Wdg - design gross weight                                   [lbs]
%   3   Nz - ultimate load factor                                   [g]
%   4   A - Aspect ratio
%   5   lambda14 - 1/4 chord sweep                                  [deg]
%   6   Vh - design cruise EAS                                      [kts]
%   7   lambda - taper ratio
%   8   tc - root t/c 
%   9   Wfw - fuel weight in wings                                  [lb]
%   10  Kb - point load position/half span
%   11  Kp - point load fraction of Wb/Wdg
%   12  Kd - distributed fuel weight as fraction of Wdg
%   13  Svt - V Tail area                                           [ft^2]
%   14  lambda14_vt - Vstab 1/4 chord sweep                         [deg]
%   15  lambda_vt - Vstab taper ratio
%   16  Sht - H Tail area                                           [ft^2]
%   17  lambda14_ht - Htail 1/4 chord sweep                         [deg]
%   18  lambda_ht - Htail taper ratio
%   19  Nl - landing load factor                                    [g]
%   20  Wl - design max landing weight                              [lb]
%   21  Lm - main gear length                                       [ft]
%   22  Ln - nose gear length                                       [ft]
%   23  Sf - Fuselage Wetted Area                                   [ft^2]
%   24  Lt - wing quarter-MAC to tail quarter-MAC                   [ft]
%   25  L_D - fuselage length to structural depth ratio
%   26  deltaP - max pressure differential (0 for unpressurized)    [psi]
%   27  Sb - Boom Wetted Area                                   [ft^2]
%   28  L_Db - boom length to structural depth ratio
%   29  Vt - fuel tank volume                                       [gal]
%   30  Vi_Vt - fraction of fuel tanks that are integral
%   31  Nt - number of tanks
%   32  Nen - number of engines
%   33  Bw - wingspan                                               [ft]
%   34  L - fuselage length                                         [ft]
%   35  Wen - uninstalled weight of one engine                      [lb]
%   36  Wuav - uninstalled avionics weight                          [lb]
%   37  Wfl - total fuel weight                                     [lb]
%   38  Vpr - pressurized volume                                    [ft^3]

%   Config vector:
%       config(1) - 0 = conventional horizantal tail or canard
%                   1 = T-tail configuration
%       config(2) - 1 = conventional single fuselage configuration
%                   2 = twin fuselage configuration
%                   3 = three fuselage/two boom configuration
%       config(3) - Number of vertical tails
%       config(4) - Number of horizontal tails

%   coords vector (all in ft)):
%   1   Wx - wing centroid x-coord
%   2   Vtx - vertical stab x-coord
%   3   Htx - horizantal stab x-coord
%   4   Mlgx - main landing gear x-coord
%   5   Nlgx - nose landing gear x-coord
%   6   Fusex - fuselage centroid x-coord
%   7   Bmx - boom centroid x-coord
%   8   Furnx - furnishings centroid x-coord
%   9   FSx - fuel systems centroid x-coord
%   10  FCx - flight control system centroid x-coord
%   11  Engx - engine cg x-coord
%   12  Avx - avionics centroid x-coord
%   13  Elcx - electrical systems centroid x-coord


%% Wing Group:
Sw = inputs(1);
Wdg = inputs(2);
Nz = inputs(3);
A = inputs(4);
lambda14 = inputs(5);
Vh = inputs(6);
lambda = inputs(7);
tc = inputs(8);
Wfw = inputs(9);
Kb = inputs(10);
Kp = inputs(11);
Kd = inputs(12);

fuelDistCorr = (1-1.2*(Kb^.42-0.7*Kp^.3*Kb)*Kp)*(1-0.8*Kd);

rhoSL = .002377; % [slug/ft^3]
q = .5*rhoSL*(Vh*1.68781)^2; % dynamic pressure calculation ----------------- NEED rhoSL

W_wing = (0.036*Sw^0.758*Wfw^0.0035*(A/cosd(lambda14)^2)^0.6*q^0.006*...
    lambda^0.04*(100*tc/(cosd(lambda14)))^-0.3*(Nz*Wdg)^0.49)*fuelDistCorr;


%% Vertical Tail
Svt = inputs(13);
lambda14_vt = inputs(14);
lambda_vt = inputs(15);

Ht_Hv = config(1);
N_Vt = config(3);

%Check this
W_vt = N_Vt*(0.073*(1 + 0.2*(Ht_Hv))*(Nz*Wdg)^0.376*q^0.122*Svt^0.873*...
    (100*tc/cosd(lambda14_vt))^-0.49*(A/(cosd(lambda14_vt)^2))^0.357*lambda_vt^0.039);


%% Horizantal Tail
Sht = inputs(16);
lambda14_ht = inputs(17);
lambda_ht = inputs(18);
N_Ht = config(4);

%Check this
W_ht = N_Ht*(0.016*(Nz*Wdg)^0.414*q^0.168*Sht^0.896*(100*tc/cosd(lambda14))^-0.12...
    *(A/(cosd(lambda14_ht)^2))^0.043*lambda_ht^-0.02);


%% Landing Gear
Nl = inputs(19);
Wl = inputs(20);
Lm = inputs(21);
Ln = inputs(22);

W_main_LG = 0.095*(Nl*Wl)^0.768*(Lm)*0.409;

W_nose_LG = 0.125*(Nl*Wl)^0.566*(Ln)^0.845;


%% Fuselage
Sf = inputs(23);
Lt = inputs(24);
L_D = inputs(25);
deltaP = inputs(26); % ---- maybe have this be in the configuration vector
Vpr = inputs(38);

if deltaP == 0 % fuselage not pressurized
    W_press = 0;
else % fuselage pressurized
    W_press = 11.9*(Vpr*deltaP)^0.271;
end

if config(2) == 1 || config(2) == 3 % single fuselage or triple config
    W_fuse = 0.052*Sf^1.086*(Nz*Wdg)^0.177*Lt^-0.051*(L_D)^-0.072*q^0.241 + W_press;
elseif config(2) == 2 % twin fuselage configuration
    W_fuse = 2*(0.052*Sf^1.086*(Nz*Wdg)^0.177*Lt^-0.051*(L_D)^-0.072*q^0.241 + W_press);
end


%% Booms
Sb = inputs(27);
L_Db = inputs(28);
Ltb = Lt;% change this

if config(2) == 3 % fuselage + two booms config
    W_booms = 2*(0.052*Sb^1.086*(Nz*Wdg)^0.177*Ltb^-0.051*(L_Db)^-0.072*q^0.241);
end


%% Furnishings
correction = W_fuse/Wdg/0.154; % correct based on fuselage weight

W_furnishing = (0.0582*Wdg - 65)*correction;


%% Fuel System
Vt = inputs(29);
Vi_Vt = inputs(30);
Nt = inputs(31);
Nen = inputs(32);
Wfl = inputs(37);

Fref = 0.8898;
K_fs = (1-.9*(Wfl/Wdg)^.8)/Fref;

W_fuelSys = K_fs*2.49*Vt^0.726*(1/(1 + Vi_Vt))^0.363*Nt^0.242*Nen^0.157;


%% Flight Control System
Bw = inputs(33);
L = inputs(34);

W_flightCon = 0.053*L^1.536*Bw^0.371*(Nz*Wdg*10^-4)^0.8;


%% Engine
Wen = inputs(35);

W_engine = 2.575*Wen^0.922*Nen;


%% Avionics
Wuav = inputs(36);

W_avionics = 2.117*Wuav^0.933;


%% Electrical System

W_elec = 12.57*(W_fuelSys + W_avionics)^0.51;


% Output Vector
weights = [W_wing, W_vt, W_ht, W_main_LG, W_nose_LG, W_fuse, W_booms, ...
    W_furnishing, W_fuelSys, W_flightCon, W_engine, W_avionics, W_elec];
W_total = sum(weights);
weights(14) = W_total;



%% Center of Gravity Calculation
Wx = coords(1);
Vtx = coords(2);
Htx = coords(3);
Mlgx = coords(4);
Nlgx = coords(5);
Fusex = coords(6);
Bmx = coords(7);
Furnx = coords(8);
FSx = coords(9);
FCx = coords(10);
Engx = coords(11);
Avx = coords(12);
Elcx = coords(13);
CG = (W_wing*Wx + W_vt*Vtx + W_ht*Htx + W_main_LG*Mlgx + W_nose_LG*Nlgx +...
    W_fuse*Fusex + W_booms*Bmx + W_furnishing*Furnx + W_fuelSys*FSx +...
    W_flightCon*FCx + W_engine*Engx + W_avionics*Avx + W_elec*Elcx)/W_total;

end




