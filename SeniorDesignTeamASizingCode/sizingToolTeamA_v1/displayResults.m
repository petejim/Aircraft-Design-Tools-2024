function [] = displayResults(inputArg1,inputArg2)
% Function to Display Results

% Store Variables
GivenVariableNames = {'Variable1', 'Variable2', 'Variable3', 'Variable4', 'Variable5'};
GivenVariables = [10, 20, 30, 40, 50];
StoredVariableNames = {'Variable1', 'Variable2', 'Variable3', 'Variable4', 'Variable5'};
StoredVariables = [10, 20, 30, 40, 50];

% Given Variables Figure
fig = figure('Position', [0, 0, 300, 300]);
title('Given Variables', 'FontName', 'Calibri', 'FontSize', 16);
for i = 1:5
    text(0.5, 1 - i * 0.1, sprintf('%s: %.2f', GivenVariableNames{i}, GivenVariables(i)), ...
        'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'right');
end
axis off;

% Calculated Variables Figure


end