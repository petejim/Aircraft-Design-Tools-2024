%% Danilo Carrasco

close all; clear; clc;

dist1 = 13500;

rangeDes = 19908;

bregTypes = [1,2];

dists = [dist1;rangeDes - dist1];

veloTAS = [146;146];

vWind = [8;8];

alt = [12000;27000];

SFCs = [0.35;0.35];

wPayload = 645;

wRF = 150;

WS = 46.4;

EWF = 0.347;

eta = 0.8;

AR = 30;

osw = 0.8;

CD0 = 0.0173;

[pp.Result] = weightFromSegments(bregTypes,dists,veloTAS,vWind,alt,SFCs,...
    wPayload,wRF,WS,EWF,eta,AR,osw,CD0);

disp("Max Takeoff = " + pp.Result(1) + " lbf")
disp("Fuel Weight = " + (pp.Result(1) - (pp.Result(1) * EWF + wPayload + wRF)) + " lbf")

pp.MTOW = pp.Result(1);

pp.fFuel = pp.Result(2:end,1);

disp("Desired range: "+ sum(dists) + " [nm]")

% "Hand Calc" to check if calculated fuel fraction acheives the desired
% range
[pp.range,x,pp.totT,t,pp.avgV] = rangeFromFuelFractions(bregTypes,pp.MTOW,pp.fFuel,dists,...
    veloTAS,vWind,alt,SFCs,WS,EWF,eta,AR,osw,CD0);

disp("Calculated range: "+ pp.range + " [nm]")

disp("Difference: " + abs(sum(dists) - pp.range) + " [nm]")

timeDays = floor(pp.totT/24);

timeHoursMinusDays = round(pp.totT - timeDays * 24);

disp("Time to complete route: " + timeDays + " days, " + timeHoursMinusDays + " hour(s)")

[pp.xMission,pp.vTASMission,pp.vGrndMission,pp.wMission,pp.rhoMission,pp.CLMission,pp.LDMission...
    ,pp.pShaftMission,pp.altMission] = missionProfileSegments3(250,[1,1],bregTypes,pp.MTOW,...
    pp.fFuel,dists,veloTAS,vWind,alt,SFCs,WS,EWF,eta,AR,osw,CD0);


figure

plot(pp.xMission,pp.pShaftMission,LineWidth=1.5)
xlabel("Distance [NM]")
ylabel("Power at Shaft [hp]")
ax = gca;
ax.XAxis.Exponent = 0;
ax.YAxis.Exponent = 0;
grid on
if dists ~= 1
    xline([cumsum(dists(1:end-1,1))],color="r",LineStyle="--")
end

LDavg1 = sum((pp.LDMission(1:end-1) + pp.LDMission(2:end)) ./ 2 .* (pp.xMission(2:end) - pp.xMission(1:end-1))) / rangeDes;

%% Unpressurized plane

dist1 = 7000;

rangeDes = 19908;

bregTypes = [1,2];

dists = [dist1;rangeDes - dist1];

veloTAS = [117;117];

vWind = [8;8];

alt = [4000;12500];

SFCs = [0.35;0.35];

wPayload = 645;

wRF = 150;

WS = 41;

EWF = 0.33;

eta = 0.8;

AR = 30;

osw = 0.8;

CD0 = 0.0173;

[up.Result] = weightFromSegments(bregTypes,dists,veloTAS,vWind,alt,SFCs,...
    wPayload,wRF,WS,EWF,eta,AR,osw,CD0);

disp("Max Takeoff = " + up.Result(1) + " lbf")
disp("Fuel Weight = " + (up.Result(1) - (up.Result(1) * EWF + wPayload + wRF)) + " lbf")

up.MTOW = up.Result(1);

up.fFuel = up.Result(2:end,1);

disp("Desired range: "+ sum(dists) + " [nm]")

% "Hand Calc" to check if calculated fuel fraction acheives the desired
% range
[up.range,x,up.totT,t,up.avgV] = rangeFromFuelFractions(bregTypes,up.MTOW,up.fFuel,dists,...
    veloTAS,vWind,alt,SFCs,WS,EWF,eta,AR,osw,CD0);

disp("Calculated range: "+ up.range + " [nm]")

disp("Difference: " + abs(sum(dists) - up.range) + " [nm]")

timeDays = floor(up.totT/24);

timeHoursMinusDays = round(up.totT - timeDays * 24);

disp("Time to complete route: " + timeDays + " days, " + timeHoursMinusDays + " hour(s)")

[up.xMission,up.vTASMission,up.vGrndMission,up.wMission,up.rhoMission,up.CLMission,up.LDMission...
    ,up.pShaftMission,up.altMission] = missionProfileSegments3(250,[1,1],bregTypes,up.MTOW,...
    up.fFuel,dists,veloTAS,vWind,alt,SFCs,WS,EWF,eta,AR,osw,CD0);

LDavg2 = sum((up.LDMission(1:end-1) + up.LDMission(2:end)) ./ 2 .* (up.xMission(2:end) - up.xMission(1:end-1))) / rangeDes;

figure

plot(up.xMission,up.pShaftMission,LineWidth=1.5)
xlabel("Distance [NM]")
ylabel("Power at Shaft [hp]")
ax = gca;
ax.XAxis.Exponent = 0;
ax.YAxis.Exponent = 0;
grid on
if dists ~= 1
    xline([cumsum(dists(1:end-1,1))],color="r",LineStyle="--")
end


%% Plots


figure

subplot(1,3,2)
plot(up.xMission,up.LDMission,"LineWidth",1.5)
hold on
plot(pp.xMission,pp.LDMission,"LineWidth",1.5)
xlabel("Distance [NM]")
ylabel("L/D")
ylim([15,35])
ax = gca;
ax.XAxis.Exponent = 0;
ax.YAxis.Exponent = 0;
% Change font to calibri 12 pt
set(gca,'FontName','Calibri','FontSize',12)
grid on


subplot(1,3,3)
plot(up.xMission,up.vTASMission,"LineWidth",1.5)
hold on
plot(pp.xMission,pp.vTASMission,"LineWidth",1.5)
xlabel("Distance [NM]")
ylabel("KTAS")
ylim([0,200])
ax = gca;
ax.XAxis.Exponent = 0;
ax.YAxis.Exponent = 0;
% Change font to calibri 12 pt
set(gca,'FontName','Calibri','FontSize',12)
grid on


subplot(1,3,1)
plot(up.xMission,up.altMission,"LineWidth",1.5)
hold on
plot(pp.xMission,pp.altMission,"LineWidth",1.5)
xlabel("Distance [NM]")
ylabel("Altitude [ft]")
ylim([0,30000])
ax = gca;
ax.XAxis.Exponent = 0;
ax.YAxis.Exponent = 0;
% Change font to calibri 12 pt
set(gca,'FontName','Calibri','FontSize',12)
grid on





