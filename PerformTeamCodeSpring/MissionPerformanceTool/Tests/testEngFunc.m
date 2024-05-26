clear all; clc; close all;

% create object of testClass
joe = testClass(5);

disp(joe.a);

engineFunc(joe, "../EngineData/CD135_SL.mat");

disp(joe.engMatSL);

