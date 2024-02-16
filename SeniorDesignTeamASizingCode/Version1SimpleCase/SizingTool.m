%% SIZING TOOL
% TEAM A: William Ho, Danilo Carrasco, Bonna H

clc; clear; close all;
addpath CarpetPlotFuncsModded/

%% START

% Define Variables
Range = 20650; % Range (in nm)
takeoffalt = 2303; % Takeoff Altitude (in feet)
runway_length = 14000; % Runway Length (in feet)
dh_dt = 25/60; % Climb Rate to Avoid Terrain (in ft/s)
eta = 0.8; % Propellor Efficiency
W_pl = 600; % Payload Weight (in lbs)

EWF = .24; % Empty Weight Fraction
CD0 = .017; % Parasitic Drag Coefficient 

%% SINGLE SEGMENTED MISSION, CONST ALTITUDE
% MISSION PROFILE INPUTS

cruisealt = 9000; % Cruise Altitude (in feet)
cruisev = 120; % Cruise Speed (in KTAS)
wind = 10; % Average Tailwind (in kts)

% PERFORMANCE INPUTS
LD = 23; % Lift to Drag Ratio
SFC = .35; % Specific-Fuel Consumption
Clmax = 1.5; % Maximum Lift Coefficient

% PLOT FORMATTING
carpetscale = 20000; % Carpet Plot Max Y-Axis
constraintscale = .07; % Constraint Diagram Max Y-Axis

% FUNCTIONS
inputVariables = [cruisealt,takeoffalt,cruisev,runway_length,dh_dt,eta,W_pl,Range,wind,LD,SFC,EWF,Clmax,CD0,carpetscale,constraintscale];
SizingToolInputs(0,0,inputVariables)
