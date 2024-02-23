%% SIZING TOOL
% TEAM A: William Ho, Danilo Carrasco, Bonna H

clc; clear; close all;
addpath CarpetPlotFuncsModded/

%% INPUT VARIABLES

% Mission Variables
Range = 20300; % Range (in nm)
takeoffalt = 2500; % Takeoff Altitude (in feet)
runway_length = 12000; % Runway Length (in feet)
dh_dt = 100/60; % Climb Rate to Avoid Terrain (in ft/s)
eta = 0.8; % Propellor Efficiency
W_pl = 800; % Payload Weight (in lbs)
EWF = .26; % Empty Weight Fraction
CD0 = .0160; % Parasitic Drag Coefficient
Clmax = 1.4; % Max Lift Coefficient
wRF = 300; % Reserve Fuel (in lbs)
WS = 29; % Wing Loading
AR = 22; % Aspect Ratio
osw = 0.9; % Oswald Efficiency
constraintscale = .07; % Constraint Diagram Max Y-Axis
carpetscale = 300000; % Carpet Plot Max Y-Axis

% % Segment Variables
% segmts = 1; % Number of Segments
% 
% % bregTypes:
% % 0: Const Alt & Cl
% % 1: Const airspeed & Cl
% % 2: Const alt & airspeed
% 
% bregTypes = 1; 
% 
% dists = Range / segmts + zeros(segmts,1); % Distance (nm)
% velocs = 110; % True Airspeed (kts)
% vWind = 17; % Avg Tailwind (kts)
% alt = 6000; % Altitude (ft)
% SFCs = .35; % Specific Fuel Consumption

% Segment Variables
segmts = 12; % Number of Segments

% bregTypes:
% 0: Const Alt & Cl
% 1: Const airspeed & Cl
% 2: Const alt & airspeed

bregTypes = [1;1;1;1;2;2;2;2;2;2;2;2]; 

dists = [1911.6; 22243.5; 2496.35; 2148.79; 1778.6; 1066.14; 1701.3; 1693.5; 1441.5; 1477.13; 474.4194; 1867.26] ; % Distance (nm)
velocs = [100;105;105;105;105;105;105;105;105;100;100;100]; % True Airspeed (kts)
vWind =  8 + zeros(segmts,1); % Avg Tailwind (kts)
alt = [0;2400;4800;7000;10000;10000;12000;11000;10000;10000;9000;8000]; % Altitude (ft)
SFCs = 0.35 + zeros(segmts,1); % Specific Fuel Consumption

% FUNCTIONS
inputVariables = [segmts,Range,takeoffalt,runway_length,dh_dt,eta,W_pl,EWF,CD0,Clmax,wRF,WS,AR,osw,constraintscale];
segmentVariables = [bregTypes,dists,velocs,vWind,alt,SFCs];

breguetSegmentTester(0,0,inputVariables,segmentVariables,0,carpetscale)
