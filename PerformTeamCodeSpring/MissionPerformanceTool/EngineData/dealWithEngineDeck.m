close all; clear; clc;

% Load the data
engine1 = load("CD135_SL.mat");

% Extract the data
engine1 = engine1.ans;

engineData = engine1;

% Save the data
save("CD135_SL.mat", "engineData");