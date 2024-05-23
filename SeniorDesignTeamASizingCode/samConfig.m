%% Danilo Carrasco

close all; clear; clc;

segmts = 2;

rangeDes = 19908;

bregTypes = 2 + zeros(segmts,1);

bregTypes(2,1) = 2;

% bregTypes(end) = 0;
% 
% bregTypes(1) = 1;

dists = rangeDes / segmts + zeros(segmts,1);

dists(1) = 10000;

dists(2) = 9908;


veloTAS   = [120.44;120.44];
vWind     = [0;0];
alt       = [8000;8000];
SFCs      = [0.355;0.355];
wPayload  = 645;
wRF       = 150;
WS        = 43.879;
EWF       = 0.3234;
eta       = 0.8;
AR        = 30;
osw       = 0.8;
CD0       = 0.017;

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


figure

plot(xMission,pShaftMission,LineWidth=1.5)
xlabel("Distance [NM]")
ylabel("Power at Shaft [hp]")
ax = gca;
ax.XAxis.Exponent = 0;
ax.YAxis.Exponent = 0;
grid on
if dists ~= 1
    xline([cumsum(dists(1:end-1,1))],color="r",LineStyle="--")
end