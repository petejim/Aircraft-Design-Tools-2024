function DragPolarDashboard()
% UI figure
drawnow;
app.UIFigure.WindowState = 'maximized';
fig = uifigure('Name', 'Aircraft Design Drag Polar Dashboard','Position', [20 0 1400 900], 'WindowState','maximized') % 'Position', [100 100 600 400],

%===========================Flight Conditions==============================
head1 = uilabel(fig, 'Position', [50 860 150 20], 'Text', 'Flight Condtions:');
head1.FontWeight = 'bold';

lblFC1 = uilabel(fig, 'Position', [50 830 150 20], 'Text', 'Flight Altitude [ft]:');
condAlt = uieditfield(fig, 'numeric', 'Position', [150 830 100 20]);

lblFC2 = uilabel(fig, 'Position', [300 830 150 20], 'Text', 'Airspeed Range [KTAS]:');
condVmin = uieditfield(fig, 'numeric', 'Position', [440 830 100 20]);
lblFC22 = uilabel(fig, 'Position', [550 830 150 20], 'Text', 'to');
condVmax = uieditfield(fig, 'numeric', 'Position', [570 830 100 20]);

conditions = [condAlt.Value condVmin.Value condVmax.Value];

%=========================Fuselage Drag Inputs=============================
head2 = uilabel(fig, 'Position', [50 800 150 20], 'Text', 'Fuselage:');
head2.FontWeight = 'bold';

% Dropdown for Engine Selection
lblEngine = uilabel(fig, 'Position', [50 690 150 20], 'Text', 'Number of Engines:');
ddEngine = uidropdown(fig, 'Position', [180 690 100 20], 'Items', {'One', 'Two'});

% Input Fields for Fuselage Geometric Parameters
lblFuseL1 = uilabel(fig, 'Position', [50 770 100 20], 'Text', 'Length A [ft]:');
fuseL(1) = uieditfield(fig, 'numeric', 'Position', [130 770 100 20]);

lblFuseL2 = uilabel(fig, 'Position', [250 770 100 20], 'Text', 'Length B [ft]:');
fuseL(2) = uieditfield(fig, 'numeric', 'Position', [330 770 100 20]);

lblFuseL3 = uilabel(fig, 'Position', [450 770 100 20], 'Text', 'Length C [ft]:');
fuseL(3) = uieditfield(fig, 'numeric', 'Position', [530 770 100 20]);

lblFuseD = uilabel(fig, 'Position', [50 730 150 20], 'Text', 'Maximum Diameter [ft]:');
fuseD = uieditfield(fig, 'numeric', 'Position', [180 730 100 20]);

lblFuseTS = uilabel(fig, 'Position', [320 730 150 20], 'Text', 'Tail Upsweep Angle [degs]:');
fuseTS = uieditfield(fig, 'numeric', 'Position', [480 730 100 20]);

lblFuseTW = uilabel(fig, 'Position', [330 690 150 20], 'Text', 'Total Takeoff Weight [lbs]:');
fuseTW = uieditfield(fig, 'numeric', 'Position', [480 690 100 20]);

fuse = [fuseL.Value fuseD.Value fuseTS.Value fuseTW.Value];

% Dropdown for Misc
lblMisc = uilabel(fig, 'Position', [350 50 150 20], 'Text', 'Misc Drag (Estimate):');
ddMisc = uidropdown(fig, 'Position', [480 50 100 20], 'Items', {'10%', '15%', '20%'});


%=========================Nacelle Drag Inputs==============================
head3 = uilabel(fig, 'Position', [50 660 150 20], 'Text', 'Nacelles:');
head3.FontWeight = 'bold';

% Dropdown for Extra Nacelle(s)
lblNacelle = uilabel(fig, 'Position', [50 590 150 20], 'Text', 'Amount of Nacelles:');
ddNacelle = uidropdown(fig, 'Position', [180 590 100 20], 'Items', {'Zero', 'One', 'Two', 'Three'});

% Input Fields for Fuselage Geometric Parameters
lblNacL1 = uilabel(fig, 'Position', [50 630 100 20], 'Text', 'Length A [ft]:');
nacL(1) = uieditfield(fig, 'numeric', 'Position', [130 630 100 20]);

lblNacL2 = uilabel(fig, 'Position', [250 630 100 20], 'Text', 'Length B [ft]:');
nacL(2) = uieditfield(fig, 'numeric', 'Position', [330 630 100 20]);

lblNacL3 = uilabel(fig, 'Position', [450 630 100 20], 'Text', 'Length C [ft]:');
nacL(3) = uieditfield(fig, 'numeric', 'Position', [530 630 100 20]);

lblNacD = uilabel(fig, 'Position', [350 590 150 20], 'Text', 'Maximum Diameter [ft]:');
nacD = uieditfield(fig, 'numeric', 'Position', [480 590 100 20]);

nac = [nacL.Value nacD.Value];


%===========================Wing Drag Inputs===============================
head4 = uilabel(fig, 'Position', [50 560 150 20], 'Text', 'Wing:');
head4.FontWeight = 'bold';

lblWingT = uilabel(fig, 'Position', [50 530 150 20], 'Text', 'Wing Thickness %:');
wingT = uieditfield(fig, 'numeric', 'Position', [180 530 100 20]);

lblWingCl = uilabel(fig, 'Position', [350 530 150 20], 'Text', 'Design Lift Coefficient:');
wingCl = uieditfield(fig, 'numeric', 'Position', [480 530 100 20]);

lblWingB = uilabel(fig, 'Position', [50 490 150 20], 'Text', 'Span of Wing [ft]:');
wingB = uieditfield(fig, 'numeric', 'Position', [180 490 100 20]);

lblWingS = uilabel(fig, 'Position', [350 490 150 20], 'Text', 'Surface Area [ft^2]:');
wingS = uieditfield(fig, 'numeric', 'Position', [480 490 100 20]);

lblWingE = uilabel(fig, 'Position', [50 450 150 20], 'Text', 'Oswald Efficiency [ft]:');
wingE = uieditfield(fig, 'numeric', 'Position', [180 450 100 20]);

% lblWingRange = uilabel(fig, 'Position', [350 450 150 20], 'Text', 'Thickness Range: 7 ≤ t ≤ 21');
% lblWingRange.FontWeight = 'bold';

wing = [wingT.Value wingCl.Value wingB.Value wingS.Value wingE.Value];

% % Dropdown for Corners
% lblNacelle = uilabel(fig, 'Position', [350 450 150 20], 'Text', 'Total # of Corners:');
% ddNacelle = uidropdown(fig, 'Position', [480 450 100 20], 'Items', {'Two (e.g. L / H Wing)', 'Four (e.g. Mid Wing)', 'Six (e.g. L | H w/ 3 Fuse)', 'Eight (e.g. Mid w/ 2 Fuse)', 'Twelve (e.g. Mid w/ 3 Fuse)'});

%===========================Tail Drag Inputs===============================
head5 = uilabel(fig, 'Position', [50 420 150 20], 'Text', 'Vertical Tail:');
head5.FontWeight = 'bold';

lblVtailThick = uilabel(fig, 'Position', [50 390 150 20], 'Text', 'Tail Thickness %:');
vtailThick = uieditfield(fig, 'numeric', 'Position', [180 390 100 20]);

lblVtailCl = uilabel(fig, 'Position', [350 390 150 20], 'Text', 'Design Lift Coefficient:');
vtailCl = uieditfield(fig, 'numeric', 'Position', [480 390 100 20]);

lblVtailB = uilabel(fig, 'Position', [50 350 150 20], 'Text', 'Span of Tail [ft]:');
vtailB = uieditfield(fig, 'numeric', 'Position', [180 350 100 20]);

lblVtailS = uilabel(fig, 'Position', [350 350 150 20], 'Text', 'Surface Area [ft^2]:');
vtailS = uieditfield(fig, 'numeric', 'Position', [480 350 100 20]);

lblVtailE = uilabel(fig, 'Position', [50 310 150 20], 'Text', 'Oswald Efficiency [ft]:');
vtailE = uieditfield(fig, 'numeric', 'Position', [180 310 100 20]);

lblVtailcor = uilabel(fig, 'Position', [350 310 150 20], 'Text', 'Chord at Root [ft]:');
vtailcor = uieditfield(fig, 'numeric', 'Position', [480 310 100 20]);

lblVtailnum = uilabel(fig, 'Position', [50 270 150 20], 'Text', 'Number of Corners:');
vtailnum = uieditfield(fig, 'numeric', 'Position', [180 270 100 20]);

vtail = [vtailThick.Value vtailCl.Value vtailB.Value vtailS.Value vtailE.Value vtailcor.Value vtailnum.Value];

head6 = uilabel(fig, 'Position', [50 240 150 20], 'Text', 'Horizontal Tail:');
head6.FontWeight = 'bold';

lblHtailThick = uilabel(fig, 'Position', [50 210 150 20], 'Text', 'Tail Thickness %:');
htailThick = uieditfield(fig, 'numeric', 'Position', [180 210 100 20]);

lblHtailCl = uilabel(fig, 'Position', [350 210 150 20], 'Text', 'Design Lift Coefficient:');
htailCl = uieditfield(fig, 'numeric', 'Position', [480 210 100 20]);

lblHtailB = uilabel(fig, 'Position', [50 170 150 20], 'Text', 'Span of Tail [ft]:');
htailB = uieditfield(fig, 'numeric', 'Position', [180 170 100 20]);

lblHtailS = uilabel(fig, 'Position', [350 170 150 20], 'Text', 'Surface Area [ft^2]:');
htailS = uieditfield(fig, 'numeric', 'Position', [480 170 100 20]);

lblHtailE = uilabel(fig, 'Position', [50 130 150 20], 'Text', 'Oswald Efficiency [ft]:');
htailE = uieditfield(fig, 'numeric', 'Position', [180 130 100 20]);

lblHtailcor = uilabel(fig, 'Position', [350 130 150 20], 'Text', 'Chord at Root [ft]:');
htailcor = uieditfield(fig, 'numeric', 'Position', [480 130 100 20]);

lblHtailnum = uilabel(fig, 'Position', [50 90 150 20], 'Text', 'Number of Corners:');
htailnum = uieditfield(fig, 'numeric', 'Position', [180 90 100 20]);

htail = [htailThick.Value htailCl.Value htailB.Value htailS.Value htailE.Value htailcor.Value htailnum.Value];

% Plot Area
ax = uiaxes(fig, 'Position', [750 250 600 600]);

% Button for Calculation
btnCalculate = uibutton(fig, 'push', 'Position', [20 50 100 22], 'Text', 'Calculate');
% btnCalculate.ButtonPushedFcn = @(btn,event) updatePlot(ax, ddEngine.Value, ddNacelle.Value, ddMisc.Value, conditions, fuse, nac, vtail, htail);
btnCalculate.ButtonPushedFcn = @(btn,event) updatePlot(ax, ...
    ddEngine.Value, ddNacelle.Value, ddMisc.Value, ...
    [condAlt.Value, condVmin.Value, condVmax.Value], ...
    [fuseL(1).Value, fuseL(2).Value, fuseL(3).Value, fuseD.Value, fuseTS.Value, fuseTW.Value], ...
    [nacL(1).Value, nacL(2).Value, nacL(3).Value, nacD.Value], ...
    [wingT.Value, wingCl.Value, wingB.Value, wingS.Value, wingE.Value], ...
    [vtailThick.Value, vtailCl.Value, vtailB.Value, vtailS.Value, vtailE.Value, vtailcor.Value, vtailnum.Value], ...
    [htailThick.Value, htailCl.Value, htailB.Value, htailS.Value, htailE.Value, htailcor.Value, htailnum.Value]);


end

function updatePlot(ax, ddEngine, ddNacelle, ddMisc, conditions, fuse, nac, wing, vtail, htail)

cla(ax,'reset')
clc

if ddEngine == "One"
    engine = 1;
else
    engine = 2;
end

CD_misc = 0;

if ddMisc == "10%"
    CD_misc = .01;
elseif ddMisc == "15%"
    CD_misc = .015;
elseif ddMisc == "20%"
    CD_misc = .02;
end

if ddNacelle == "One"
    n_emp = 1;
elseif ddNacelle == "Two"
    n_emp = 2;
elseif ddNacelle == "Three"
    n_emp = 3;
elseif ddNacelle == "Zero"
    n_emp = 0;
end

KTAS = linspace(conditions(2), conditions(3), 50); % Knots True Airspeed
Cond = [conditions(1), KTAS];
tratio = [htail(1)/100 vtail(1)/100];
c = [htail(6) vtail(6)];
nc = [htail(7) vtail(7)];
S = [htail(4) vtail(4)];
S_ref = wing(4);

% Wing Calculations
for r = 1:length(KTAS)
[Clw(r), Cd0w(r), Cdiw(r)] = wingDrag(wing(1), wing(2), wing(5), wing(4), 2*wing(3), fuse(6), KTAS(r), conditions(1));
CD_Wing(r) = (Cd0w(r) + Cdiw(r))*(wing(4)/S_ref);
end

% Tail Calculations
[Clhs, Cd0hs, ~] = tailDrag(htail(1), htail(2), htail(5), htail(4), 2*htail(3));
CD_HS = Cd0hs*(htail(4)/S_ref);

[Clvs, Cd0vs, ~] = tailDrag(vtail(1), vtail(2), vtail(5), vtail(4), 2*vtail(3));
CD_VS = Cd0vs*(vtail(4)/S_ref);

% Fuselage Calculations
[Cd0f, S_Fuse] = fuselageDrag([fuse(1) fuse(2) fuse(3)], fuse(4), Cond, engine, fuse(5));
CD_Fuse = Cd0f*(S_Fuse/S_ref);

% Nacelle Calculations
[Cd0n, S_Nac] = nacelleDrag([nac(1) nac(2) nac(3)], nac(4), Cond, n_emp);
CD_Nac = Cd0n*(S_Nac/S_ref);

CD0FN = [CD_Fuse CD_Nac];

% Interference Calculations
[CD_int] = interferenceDrag(CD0FN, n_emp, tratio, c, nc, S);

n = linspace(1,50,50);

CD = (CD_Wing + CD_Fuse + CD_HS + CD_VS + CD_int)*(1+CD_misc);

minimumDrag = min(CD);

y = [CD_Wing CD_Fuse CD_HS CD_VS CD_int CD_misc];


disp(['The minimum Drag Coefficient is ', num2str(minimumDrag)])

% Plot Figure
hold(ax, 'on' )

plot(ax, CD, Clw, 'o-r');
plot(ax, Cdiw, Clw, 'o-b');
title(ax, 'Aircraft Drag Polar');
ylabel(ax, 'Lift Coefficient (Cl)');
xlabel(ax, 'Drag Coefficient (Cd)');
hold(ax, 'off' )
end