% Compares diffrent tailwind files

close all; clear; clc;

fileMe = load("../WindDataLoaded/2023-12-01-10days.mat");
% load("../../../Team 1 - Parameters/Dec1-Dec10_tailwind.mat")
% load("../../../Team 1 - Parameters/Dec1-Dec10_crosswind.mat")
% load("../../../Team 1 - Parameters/SouthHem_Team1_100NM_distance.mat")
load("../WindDataLoaded/chrisVindicated.mat")

for i = 1:10
    figure
    title("day: " + i)
    subplot(2,1,1)
    hold on
    for j = 1:6
        plot(fileMe.tailwinds{i}(j,:))
    end
    ylim([0,30])
    grid on
    hold off
    subplot(2,1,2)
    hold on
    for j = 1:6
        plot(all_tailwind{i}(j,:))
    end
    ylim([0,30])
    grid on
    hold off

end