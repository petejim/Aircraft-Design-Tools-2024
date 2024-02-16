%% SIZING TOOL
% TEAM A: William Ho, Danilo Carrasco, Bonna H

clc; clear; close all;
addpath CarpetPlotFuncsModded/

%% INPUT VARIABLES

% Mission Variables
Range = 20650; % Range (in nm)
takeoffalt = 2303; % Takeoff Altitude (in feet)
runway_length = 14000; % Runway Length (in feet)
dh_dt = 25/60; % Climb Rate to Avoid Terrain (in ft/s)
eta = 0.8; % Propellor Efficiency
W_pl = 600; % Payload Weight (in lbs)
EWF = .24; % Empty Weight Fraction
CD0 = .0270; % Parasitic Drag Coefficient
Clmax = 1.5; % Max Lift Coefficient
wRF = 300; % Reserve Fuel (in lbs)
WS = 35.5; % Wing Loading
AR = 37.5; % Aspect Ratio
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
segmts = 7; % Number of Segments

% bregTypes:
% 0: Const Alt & Cl
% 1: Const airspeed & Cl
% 2: Const alt & airspeed

bregTypes = 2 + zeros(segmts,1); 

dists = Range / segmts + zeros(segmts,1); % Distance (nm)
velocs = [105;105;105;105;105;105;105]; % True Airspeed (kts)
vWind = 5 + zeros(segmts,1); % Avg Tailwind (kts)
alt = [6000;7000;8000;9000;10000;11000;12000]; % Altitude (ft)
SFCs = 0.35 + zeros(segmts,1); % Specific Fuel Consumption

% FUNCTIONS
inputVariables = [segmts,Range,takeoffalt,runway_length,dh_dt,eta,W_pl,EWF,CD0,Clmax,wRF,WS,AR,osw,constraintscale];
segmentVariables = [bregTypes,dists,velocs,vWind,alt,SFCs];

breguetSegmentTester(0,0,inputVariables,segmentVariables,0,carpetscale)
