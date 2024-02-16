

close all; clear; clc;

segmts = 14;

bregTypes = [1; 0; 0; 1; 1; 0; 1; 0; 0; 2; 0; 2; 2; 2];

dists = [2176; 2165; 1303; 1378; 1294; 1744; 2284; 868; 2092; 926; 2195; 841; 1850; 930];

veloTAS = [118; 118; 109; 103; 100; 100; 95; 92; 88; 80; 80; 74; 73; 72];

vWind = [5.167; 10; 15; 17; 20; 10; 5; -3; -4; 14; 20; 25; 12; -5];

alt = [0; 5000; 5000; 5000; 7500; 10000; 10000; 15000; 11000; 7000; 5000; 5000; 5000; 3000];

SFCs = 0.35 + zeros(segmts,1);

wPayload = 433;

wRF = 110;

WS = 31.2;

EWF = 0.16;

eta = 0.8;

AR = 33.8;

osw = 0.85;

CD0 = 0.032;

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

