


clear; close all; clc;

% Load the data

dataStruct = load("CurrentConfigMissionProfile.mat");

% Index into the cell to get the table cell
tableCell = dataStruct.all_results_table;

% Convert the table cell to a table
dataTable = tableCell{1,1};

% Convert the table to an excel file
writetable(dataTable, 'MissionPerformanceResults.xlsx');

% Save the table as matlab file
save('MissionPerformanceResults.mat', 'dataTable');