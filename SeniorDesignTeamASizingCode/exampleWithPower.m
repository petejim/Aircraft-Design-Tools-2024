%% Danilo Carrasco

close all; clear; clc;

dist1 = 14500;

rangeDes = 19908;

bregTypes = [1,2];

dists = [dist1;rangeDes - dist1];

veloTAS = [146;146];

vWind = [8;8];

alt = [10000;27000];

SFCs = [0.35;0.35];

wPayload = 645;

wRF = 150;

WS = 46.4;

EWF = 0.347;

eta = 0.8;

AR = 30;

osw = 0.8;

CD0 = 0.0173;

disp(1/(pi * AR * osw))

[Result] = weightFromSegments(bregTypes,dists,veloTAS,vWind,alt,SFCs,...
    wPayload,wRF,WS,EWF,eta,AR,osw,CD0);

disp("Max Takeoff = " + Result(1) + " lbf")
disp("Fuel Weight = " + (Result(1) - (Result(1) * EWF + wPayload + wRF)) + " lbf")

MTOW = Result(1);

fFuel = Result(2:end,1);

disp("Desired range: "+ sum(dists) + " [nm]")

% "Hand Calc" to check if calculated fuel fraction acheives the desired
% range
[range,x,totT,t,avgV] = rangeFromFuelFractions(bregTypes,MTOW,fFuel,dists,...
    veloTAS,vWind,alt,SFCs,WS,EWF,eta,AR,osw,CD0);

disp("Calculated range: "+ range + " [nm]")

disp("Difference: " + abs(sum(dists) - range) + " [nm]")

timeDays = floor(totT/24);

timeHoursMinusDays = round(totT - timeDays * 24);

disp("Time to complete route: " + timeDays + " days, " + timeHoursMinusDays + " hour(s)")

[xMission,vTASMission,vGrndMission,wMission,rhoMission,CLMission,LDMission...
    ,pShaftMission] = missionProfileSegments3(100,[1,1],bregTypes,MTOW,...
    fFuel,dists,veloTAS,vWind,alt,SFCs,WS,EWF,eta,AR,osw,CD0);

LDavg = sum((LDMission(1:end-1) + LDMission(2:end)) ./ 2 .* (xMission(2:end) - xMission(1:end-1))) / range;

disp(LDavg)



figure

plot(xMission,pShaftMission,LineWidth=1.5)
xlabel("Distance [NM]")
ylabel("Power at Shaft [hp]")
ax = gca;
ax.XAxis.Exponent = 0;
ax.YAxis.Exponent = 0;
grid on
if length(dists) ~= 1
    xline([cumsum(dists(1:end-1,1))],color="r",LineStyle="--")
end