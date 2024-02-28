% Aero 443 team 1 baseline

% INPUTS:
%   inputs - vector of all necessary inputs (in order):
Sw = 270; %- wing area                                              [ft^2]
Wdg = 11080; % - design gross weight                                   [lbs]
Nz = 3; % - ultimate load factor                                   [g]
A = 30; % - Aspect ratio
lambda14 = 0; % - 1/4 chord sweep                                  [deg]
Vh = 112; %- design cruise EAS                                      [kts]
lambda = 0.51; % - taper ratio
tc = 0.15; % - root t/c ARBITRARY, not chosen last quarter
Wfw = 2500;% - fuel weight                                           [lb]
Kb = 0.33; % - point load position/half span
Kp = 0.45; % - point load fraction of Wb/Wdg
Kd = 0.227;% - distributed fuel weight as fraction of Wdg
Svt = 11.2;% - V Tail area                                           [ft^2]
lambda14_vt = 7; % - Vstab 1/4 chord sweep                         [deg]
lambda_vt = 0.56;% - Vstab taper ratio
Sht = 13.38;% - H Tail area                                           [ft^2]
lambda14_ht = 0;% - Htail 1/4 chord sweep                         [deg]
lambda_ht = 0.5; % - Htail taper ratio
Nl = 3;% - landing load factor                                    [g]
Wl = 7202;% - design max landing weight                              [lb]
Lm = 46/12;% - main gear length                                       [ft]
Ln = 30/12;% - nose gear length                                       [ft]
Sf=140;% - Fuselage Wetted Area                                   [ft^2]
Lt = 20;% - wing quarter-MAC to tail quarter-MAC                   [ft]
L_D = 5;% - fuselage length to structural depth ratio
deltaP = 0;% - max pressure differential (0 for unpressurized)    [psi]
Sb = 97;% - Boom Wetted Area                                   [ft^2]
L_Db = 12;% - boom length to structural depth ratio
Vt = 757;% - fuel tank volume                                       [gal]
Vi_Vt = 1;% - fraction of fuel tanks that are integral
Nt = 8;% - number of tanks
Nen = 2;% - number of engines
Bw = 90;% - wingspan                                               [ft]
L = 30;% - fuselage length                                         [ft]
Wen=372.4;% - uninstalled weight of one engine                      [lb]
Wuav = 40;% - uninstalled avionics weight                          [lb]
Wfl = 7500;% - total fuel weight                                     [lb]
Vpr = 97;% - pressurized volume                                      [ft^3]

bl_inputs = [Sw,Wdg,Nz,A,lambda14,Vh,lambda,tc,Wfw,Kb,Kp,Kd,Svt,lambda14_vt,lambda_vt,Sht,lambda14_ht,lambda_ht,Nl,Wl,Lm,Ln,Sf,Lt,L_D,deltaP,Sb,L_Db,Vt,Vi_Vt,Nt,Nen,Bw,L,Wen,Wuav,Wfl,Vpr];



%   Config vector:
bl_config(1) = 0;
bl_config(2) = 3;
bl_config(3) = 2;
bl_config(4) = 2;

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
bl_coords = zeros(1,13);


[weights, CG] = mass_props(bl_inputs, bl_config, bl_coords);

%weights = [W_wing, W_vt, W_ht, W_main_LG, W_nose_LG, W_fuse, W_booms, ...
%    W_furnishing, W_fuelSys, W_flightCon, W_engine, W_avionics, W_elec];
disp("Wing: "+weights(1))
disp("V Tail: "+weights(2))
disp("H Tail: "+weights(3))
disp("Main LG: "+weights(4))
disp("Nose LG: "+weights(5))
disp("fuse: "+weights(6))
disp("booms: "+weights(7))
disp("furnishing: "+weights(8))
disp("fuel system: "+weights(9))
disp("flight controls: "+weights(10))
disp("engine: "+weights(11))
disp("avionics: "+weights(12))
disp("Electrical: "+weights(13))
disp("We: "+weights(14))
bl_We = weights(14);

%% Boom position
KbSweep = linspace(0.2,0.5);
for i = 1:length(KbSweep)
    KbSweep_inputs = bl_inputs;
    KbSweep_inputs(10) = KbSweep(i);
    weights = mass_props(KbSweep_inputs, bl_config, bl_coords);
    KbSweep_We(i) = weights(14);
end
figure(1)
plot(KbSweep,KbSweep_We)
title("Empty Weight vs K_b")

%% Landing Weight

%% Turboprop
%Based on PBS TP100 and TDA CR 2.0 for cruise
% 404 HP max continuous vs baseline 325
Wen_TP = (452+136)/2;
TP_inputs = bl_inputs;
TP_inputs(35) = Wen_TP;
TP_weights = mass_props(TP_inputs, bl_config, bl_coords);
TP_We = TP_weights(14);
TP_ewf = TP_We/11080;
%% Pressurization
%function [Tstd, P, rhostd, rho] = standatm(alt, T, unit)
[~, P_10k, ~, ~] = standatm(10000,0,"IMP");

Pr_alt = linspace(15000,30000);
for i = 1:length(Pr_alt)
    [~, P_alt, ~, ~] = standatm(Pr_alt(i),0,"IMP");
    Pr_deltaP = (P_10k-P_alt)/144;
    Pr_inputs = bl_inputs;
    Pr_inputs(26) = Pr_deltaP;
    weights = mass_props(Pr_inputs, bl_config, bl_coords);
    Pr_We(i) = weights(14);
end
Pr_ewf = Pr_We./11080;
figure(2)
plot(Pr_alt,Pr_We)
title("Empty Weight vs Ceiling for 10000 ft Cabin Alt")
figure(3)
plot(Pr_alt,Pr_ewf)
title("EWF vs Ceiling for 10000 ft Cabin Alt")

%% Reduced landing weight
frac_fuel = linspace(0,1);
W_LDG = 4150+6930.*frac_fuel;
for i = 1:length(frac_fuel)
    lw_inputs = bl_inputs;
    lw_inputs(20) = W_LDG(i);
    weights = mass_props(lw_inputs, bl_config, bl_coords);
    lw_We(i) = weights(14);
end
lw_ewf = lw_We./11080;
figure(4)
plot(frac_fuel,lw_We)
title("Empty Weight vs Max Landing Fuel Fraction")
figure(5)
plot(frac_fuel,lw_ewf)
title("EWF vs Landing max fuel fraction")

%% reduced aspect ratio
% INPUTS:
%   inputs - vector of all necessary inputs (in order):
Sw = 290; %- wing area                                              [ft^2]
Wdg = 11080; % - design gross weight                                   [lbs]
Nz = 3; % - ultimate load factor                                   [g]
A = 25; % - Aspect ratio
lambda14 = 0; % - 1/4 chord sweep                                  [deg]
Vh = 112; %- design cruise EAS                                      [kts]
lambda = 0.51; % - taper ratio
tc = 0.15; % - root t/c ARBITRARY, not chosen last quarter
Wfw = 3175;% - fuel weight                                           [lb]
Kb = 0.33; % - point load position/half span
Kp = 0.39; % - point load fraction of Wb/Wdg
Kd = 0.2865;% - distributed fuel weight as fraction of Wdg
Svt = 11.2;% - V Tail area                                           [ft^2]
lambda14_vt = 7; % - Vstab 1/4 chord sweep                         [deg]
lambda_vt = 0.56;% - Vstab taper ratio
Sht = 13.38;% - H Tail area                                           [ft^2]
lambda14_ht = 0;% - Htail 1/4 chord sweep                         [deg]
lambda_ht = 0.5; % - Htail taper ratio
Nl = 3;% - landing load factor                                    [g]
Wl = 7202;% - design max landing weight                              [lb]
Lm = 46/12;% - main gear length                                       [ft]
Ln = 30/12;% - nose gear length                                       [ft]
Sf=140;% - Fuselage Wetted Area                                   [ft^2]
Lt = 20;% - wing quarter-MAC to tail quarter-MAC                   [ft]
L_D = 5;% - fuselage length to structural depth ratio
deltaP = 0;% - max pressure differential (0 for unpressurized)    [psi]
Sb = 85;% - Boom Wetted Area                                   [ft^2]
L_Db = 13.8;% - boom length to structural depth ratio
Vt = 757;% - fuel tank volume                                       [gal]
Vi_Vt = 1;% - fraction of fuel tanks that are integral
Nt = 8;% - number of tanks
Nen = 2;% - number of engines
Bw = 90;% - wingspan                                               [ft]
L = 30;% - fuselage length                                         [ft]
Wen=372.4;% - uninstalled weight of one engine                      [lb]
Wuav = 40;% - uninstalled avionics weight                          [lb]
Wfl = 7500;% - total fuel weight                                     [lb]
Vpr = 97;% - pressurized volume                                      [ft^3]

lo_AR_inputs = [Sw,Wdg,Nz,A,lambda14,Vh,lambda,tc,Wfw,Kb,Kp,Kd,Svt,lambda14_vt,lambda_vt,Sht,lambda14_ht,lambda_ht,Nl,Wl,Lm,Ln,Sf,Lt,L_D,deltaP,Sb,L_Db,Vt,Vi_Vt,Nt,Nen,Bw,L,Wen,Wuav,Wfl,Vpr];


[lo_AR_weights, lo_AR_CG] = mass_props(lo_AR_inputs, bl_config, bl_coords);

%weights = [W_wing, W_vt, W_ht, W_main_LG, W_nose_LG, W_fuse, W_booms, ...
%    W_furnishing, W_fuelSys, W_flightCon, W_engine, W_avionics, W_elec];
% disp("Wing: "+weights(1))
% disp("V Tail: "+weights(2))
% disp("H Tail: "+weights(3))
% disp("Main LG: "+weights(4))
% disp("Nose LG: "+weights(5))
% disp("fuse: "+weights(6))
disp("booms: "+lo_AR_weights(7))
% disp("furnishing: "+weights(8))
% disp("fuel system: "+weights(9))
% disp("flight controls: "+weights(10))
% disp("engine: "+weights(11))
% disp("avionics: "+weights(12))
% disp("Electrical: "+weights(13))
disp("Low AR We: "+lo_AR_weights(14))
lo_AR_We = lo_AR_weights(14);


%% Design Speed
Vc = linspace(112,150);
for i = 1:length(Vc)
    vc_inputs = bl_inputs;
    vc_inputs(6) = Vc(i);
    weights = mass_props(vc_inputs, bl_config, bl_coords);
    vc_We(i) = weights(14);
end
figure(6)
plot(Vc,vc_We)
title("Empty Weight vs Design Cruise Speed")

%% long cockpit
% cockpit is now 12 feet long, landing weight lowered

% INPUTS:
%   inputs - vector of all necessary inputs (in order):

Sw = 270; %- wing area                                              [ft^2]
Wdg = 11080; % - design gross weight                                   [lbs]
Nz = 3; % - ultimate load factor                                   [g]
A = 30; % - Aspect ratio
lambda14 = 0; % - 1/4 chord sweep                                  [deg]
Vh = 112; %- design cruise EAS                                      [kts]
lambda = 0.51; % - taper ratio
tc = 0.15; % - root t/c ARBITRARY, not chosen last quarter
Wfw = 2500;% - fuel weight                                           [lb]
Kb = 0.33; % - point load position/half span
Kp = 0.45; % - point load fraction of Wb/Wdg
Kd = 0.227;% - distributed fuel weight as fraction of Wdg
Svt = 11.2;% - V Tail area                                           [ft^2]
lambda14_vt = 7; % - Vstab 1/4 chord sweep                         [deg]
lambda_vt = 0.56;% - Vstab taper ratio
Sht = 13.38;% - H Tail area                                           [ft^2]
lambda14_ht = 0;% - Htail 1/4 chord sweep                         [deg]
lambda_ht = 0.5; % - Htail taper ratio
Nl = 3;% - landing load factor                                    [g]
Wl = 4850;% - design max landing weight                              [lb]
Lm = 46/12;% - main gear length                                       [ft]
Ln = 30/12;% - nose gear length                                       [ft]
Sf=210;% - Fuselage Wetted Area                                   [ft^2]
Lt = 20;% - wing quarter-MAC to tail quarter-MAC                   [ft]
L_D = 6.4;% - fuselage length to structural depth ratio
deltaP = 0;% - max pressure differential (0 for unpressurized)    [psi]
Sb = 97;% - Boom Wetted Area                                   [ft^2]
L_Db = 12;% - boom length to structural depth ratio
Vt = 757;% - fuel tank volume                                       [gal]
Vi_Vt = 1;% - fraction of fuel tanks that are integral
Nt = 8;% - number of tanks
Nen = 2;% - number of engines
Bw = 90;% - wingspan                                               [ft]
L = 30;% - fuselage length                                         [ft]
Wen=372.4;% - uninstalled weight of one engine                      [lb]
Wuav = 40;% - uninstalled avionics weight                          [lb]
Wfl = 7500;% - total fuel weight                                     [lb]
Vpr = 166;% - pressurized volume                                      [ft^3]

long_fuse_inputs = [Sw,Wdg,Nz,A,lambda14,Vh,lambda,tc,Wfw,Kb,Kp,Kd,Svt,lambda14_vt,lambda_vt,Sht,lambda14_ht,lambda_ht,Nl,Wl,Lm,Ln,Sf,Lt,L_D,deltaP,Sb,L_Db,Vt,Vi_Vt,Nt,Nen,Bw,L,Wen,Wuav,Wfl,Vpr];


[long_fuse_weights, long_fuse_CG] = mass_props(long_fuse_inputs, bl_config, bl_coords);
disp("Wing: "+long_fuse_weights(1))
disp("V Tail: "+long_fuse_weights(2))
disp("H Tail: "+long_fuse_weights(3))
disp("Main LG: "+long_fuse_weights(4))
disp("Nose LG: "+long_fuse_weights(5))
disp("fuse: "+long_fuse_weights(6))
disp("booms: "+long_fuse_weights(7))
disp("furnishing: "+long_fuse_weights(8))
disp("fuel system: "+long_fuse_weights(9))
disp("flight controls: "+long_fuse_weights(10))
disp("engine: "+long_fuse_weights(11))
disp("avionics: "+long_fuse_weights(12))
disp("Electrical: "+long_fuse_weights(13))
disp("We: "+long_fuse_weights(14))
lf_We = long_fuse_weights(14);
