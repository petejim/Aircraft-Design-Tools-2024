%% Danilo Carrasco

close all; clear; clc;

segmts = 100;

rangeDes = 20000;

bregTypes = 1 + zeros(segmts,1);

% bregTypes(end) = 0;
% 
% bregTypes(1) = 1;

dists = rangeDes / segmts + zeros(segmts,1);

veloTAS = 90 + zeros(segmts,1);
% velocs = [100;100;100;90];

vWind = 15 + zeros(segmts,1);

alt = 0 + zeros(segmts,1);
% alt = [10000;12500;15000;15000];

SFCs = 0.36 + zeros(segmts,1);

wPayload = 600;

wRF = 100;

WS = 35;

EWF = 0.24;

eta = 0.8;

AR = 20;

osw = 0.9;

CD0 = 0.0270;

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

[xMission,vMission,wMission,rhoMission,CLMission,LDMission] = ...
    missionProfileSegments(10,[1,1],bregTypes,MTOW,fFuel,...
    dists,veloTAS,vWind,alt,SFCs,WS,EWF,eta,AR,osw,CD0);



