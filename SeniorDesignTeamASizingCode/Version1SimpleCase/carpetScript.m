

clear; close all; clc;

addpath CarpetPlotFuncsModded\

% propeller efficiency
eta = 0.8;

% LD estimations
LD = [20:1:30]; % lb/hp/hr, numbers based on competitive assessment plot

% SFC estimation
SFC = [0.3:.0125:.425]; % from engine competitive assessment

% EWF estimation
EWF = [0.20:.01:.30];

% Payload weight requirement
W_pl = 600; % lbs

% Range requirement
R = 20650; % nm

carpetPlotFunction(eta,LD,SFC,EWF,W_pl,R);