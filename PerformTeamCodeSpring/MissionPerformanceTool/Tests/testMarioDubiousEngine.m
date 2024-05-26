clear; close all; clc;

addpath("../../../EngineModelCode/")

seaLevelEngine = BuildEngineDeck('D', 0.35, 135, 50);

altitudes = linspace(0,20000,9);

plot(seaLevelEngine(:,1), seaLevelEngine(:,2))
ylim([0.3,0.5])
hold on;

for i = 1:length(altitudes)
    
    matrix(:,:,i) = ChangeEngineAlt('D',seaLevelEngine,0.35,altitudes(i),6000,50);
    plot(matrix(:,1,i),matrix(:,2,i))
    scatter(matrix(end,1,i),matrix(end,2,i))
    scatter(matrix(1,1,i),matrix(1,2,i))
    hold on;

end
