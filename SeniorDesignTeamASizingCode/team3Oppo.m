%% Danilo Carrasco

close all; clear; clc;

% 9077

% 3105

dist1 = 5500;

%
rangeDes = 20290;

%
bregTypes = [1,2];

dists = [dist1;rangeDes - dist1];

%
veloTAS = [102-6.5;102-6.5];

%
vWind = [6.5;6.5];

%
alt = [3000;10000];

%
SFCs = [0.358;0.358];

%
wPayload = 700;

% This seems to be their effective reserve based on the requirements
wRF = 110;

WS = 29;

EWF = 0.33;

eta = 0.8;

AR = 22;

osw = 0.8;

CD0 = 0.0147;

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