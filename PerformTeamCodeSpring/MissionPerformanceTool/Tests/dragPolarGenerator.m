% Script takes a drag polar from excel and turns it into a matlab array

clear; close all; clc;

% Load in the drag polar data
dragPolar = readmatrix("../DragPolars/aethon_5_10.xlsx");

% Print the drag polar data
disp(dragPolar);