clc;
clear;
close all;

% Drag Build Up Tool

%===========================Flight Conditions==============================
n = 200;
alt = 10000; % ft
KTAS = 120; % Knots True Airspeed
Cl = linspace(0, 1.5, n);
W = 11080;
S_ref = 270; % Aircraft Reference Area (ft^2) 

%===========================Wing Drag Inputs===============================
%Wing Properties
t_wing = 20;  % Maximum Thickness in %
c_wing = 7;   % Designed Cl (Divide by 10)
b_wing = 90;  % Span of the Wing (ft)
S_wing = 246; % Exposed Wing Area (ft^2) - not including fuselage 
e_wing = 0.6; % Oswald Efficiency

%=========================Empanage Drag Inputs=============================
%Horizontal Stabilizer Airfoil Properties
t_hs = 18;       % Maximum Thickness in %
c_hs = 0;       % Designed Cl (Divide by 10)
b_hs = 11;      % Span of the Tail (ft)
S_hs = 12.98;      % Reference Area of the Tail
cor_hs = 1.56; % Chord at Fuselage (ft)
e_hs = 0.8;     % Oswald Efficiency
nc_hs = 4;      % Number of Corners
tratio_hs = (t_hs/100);

%Vertical Stabilizer Airfoil Properties
t_vs = 18;  % Maximum Thickness in %
c_vs = 0;   % Designed Cl (Divide by 10)
b_vs = 5.32;   % Span of the Tail (ft)
S_vs = 6.2776;  % Reference Area of the Tail
cor_vs = 1.56; % Chord at Fuselage (ft)
e_vs = 0.8; % Oswald Efficiency
nc_vs = 4;  % Number of Corners
tratio_vs = (t_vs/100);

n_emp = 2;  % Number of Empanages

%=========================Fuselage Drag Inputs=============================
%Fuselage Properties
L_fuse = [2.86, 7.49, 2.65]; % Lengths of the three Segments (ft)
D_fuse = 4;         % Maximum Diameter of the Fuselage (ft)
n_eng = 2;          % 1=1 engine on front, 2=two engines on front and back
t_upsweep = 10;      % Degree of tail upsweep

%=========================Nacelle Drag Inputs==============================
%Nacelle Properties
L_Nacelle = [7.91, 9.4, 12.69]; % Lengths of the three Segments (ft)
D_Nacelle = 2;            % Maximum Diameter of the Fuselage (ft)
n_Nacelle = 2;            % Number of Nacelles

%=============================Misc Drag====================================
CD_misc = 0.3;

%==========================================================================

% defining vector variables for functions
Cond = [alt, KTAS];
tratio = [tratio_hs tratio_vs];
c = [cor_hs cor_vs];
nc = [nc_hs nc_vs];
S = [S_hs S_vs];

% ===========================Functions=====================================
% wing drag

[Clw, Cd0w, Cdiw] = wingDrag(t_wing, c_wing, e_wing, S_wing, b_wing, Cl);
CD_Wing0 = (Cd0w)*(S_wing/S_ref);
CD_Wingi = Cdiw*(S_wing/S_ref);

% horizontal tail daig
[Clhs, Cd0hs, ~] = tailDrag(t_hs, c_hs, e_hs, S_hs, b_hs);
CD_HS = Cd0hs*(S_hs/S_ref)*n_emp; % normalizing value to surface area

% vertical tail drag
[Clvs, Cd0vs, ~] = tailDrag(t_vs, c_vs, e_vs, S_vs, b_vs);
CD_VS = Cd0vs*(S_vs/S_ref)*n_emp; % normalizing

% fuselage drag
[Cd0f, S_Fuse] = fuselageDrag(L_fuse, D_fuse, Cond, n_eng, t_upsweep);
CD_Fuse = Cd0f*(S_Fuse/S_ref); % normalizing

% nacelle drag
[Cd0n, S_Nac] = nacelleDrag(L_Nacelle, D_Nacelle, Cond, n_Nacelle);
CD_Nac = Cd0n*(S_Nac/S_ref)*n_Nacelle; % normalizing

% interference drag
CD0FN = [CD_Fuse CD_Nac];

[CD_int] = interferenceDrag(CD0FN, n_Nacelle, tratio, c, nc, S, S_ref);

% total drag
CD = ((CD_Wing0 + CD_Fuse + CD_HS + CD_VS + CD_int)*(1+CD_misc)) + CD_Wingi;

% y = [CD_Wing CD_Fuse CD_HS CD_VS CD_int CD_misc];
P = polyfit(Clw, CD, 2);
pv = polyval(P, Clw);

% plot
figure('Name','Design Team 1 Test Case', 'NumberTitle', 'off','Position',[300,225,900,500])
hold on
plot(pv, Clw, 'linewidth', 2)
xlabel('{C}_{D}')
ylabel('{C}_{L}')
yticks(linspace(0, 1.5, 7))
axis([0 0.055 0 1.5])
set(gca, 'fontname', 'trebuchet', 'fontsize', 20)
grid on

save("OEDT1.mat","pv","Clw")

LD = Clw./pv;

figure
plot(Clw, LD)

% minimum drag
P = polyfit(Clw, CD, 2);
pv = polyval(P, Clw);
minimumDrag = P(3);

LDmax = max(LD);

% display helpful values
disp(['The Minimum Drag Coefficient is ', num2str(minimumDrag)])
disp(['The Drag Polar Equation is ', num2str(P(1)),'x^2 + ', num2str(P(2)), 'x + ', num2str(P(3))])
disp(['The Max L/D is ', num2str(LDmax)])