%% Design sizing software
% 

clear all
close all
clc

%% Breguet Range Equation

% propeller efficiency
eta = 0.8;

% LD estimations
LD = [22:1:33]; % lb/hp/hr, numbers based on competitive assessment plot

% SFC estimation 
SFC = [.25:.02:.375]; % from engine competitive assessment

% EWF estimation 
EWF = [0.17:.02:.25];

% Payload weight requirement
W_pl = 800; % labs

% Range requirement
R = 21000; % nm

% takeoff weight initial guess (approx voyager takeoff weight)
W_to_i = 10000; % lbs


%% run function

%[W_to, W_e, W_f] = sizing1(LD, SFC, EWF, W_pl, R, eta, W_to_i);

for (i = 1:length(LD))
    for j = 1:length(SFC)
        for k = 1:length(EWF)
            [W_to(i,j,k), W_e(i,j,k), W_f(i,j,k)] = sizing1(LD(i), SFC(j), EWF(k), W_pl, R, eta, W_to_i);
        end
    end
end


%% carpet plot

figure(1)
hold on
[X,Y] = meshgrid(LD,SFC);
offset = 20;
Z = reshape(W_to(:,:,3),[length(LD),length(SFC)]);
Z = Z';

carpet(X,Y,Z,offset,0,'b','r','LineWidth',1.25);

h = carpetlabel(X, Y, Z, offset, 0, 1, 0, .2, 1.2,'FontSize', 13);
h = carpetlabel(X, Y, Z, offset, 0, 0, -1, -.6, 0,'FontSize',13);

carpettext(X,Y,Z, offset, 23, 0.35, "L/D", 4, 2.5,'FontSize',17);
carpettext(X,Y,Z, offset, 22, 0.33, "SFC", -1.75, 0,'FontSize',17);

ylim([.19e4 2e4])
xlim([25.5,41.5])
ax = gca;
ax.YRuler.Exponent = 0;

ylabel('Maximum Takeoff Weight (lbs)','FontSize',18)
set(ax,'FontSize',14)

hold off

% figure(2)
% hold on
% [X,Y] = meshgrid(LD,EWF);
% offset = 20;
% Z = reshape(W_to(:,6,:),[length(LD),length(EWF)]);
% Z = Z';
% 
% carpet(X,Y,Z,offset,0,'b','r','LineWidth',1.25);
% 
% h = carpetlabel(X, Y, Z, offset, 0, 1, 0, .2,1.2,'FontSize', 13);
% h = carpetlabel(X, Y, Z, offset, 0, 0, -1, -.8, 0,'FontSize',13);
% 
% carpettext(X,Y,Z, offset, 24, 0.25, "L/D", 1.5, 0,'FontSize',17);
% carpettext(X,Y,Z, offset, 22.2, 0.24, "EWF", -2, 0,'FontSize',17);
% 
% ylim([.21e4 3e4]);
% xlim([24,39]);
% ax2 = gca;
% ax2.YRuler.Exponent = 0;
% 
% ylabel('Maximum Takeoff Weight (lbs)','FontSize',18);
% set(ax2,'FontSize',14)
% 
% 
% hold off


% h_1 = carpetlabel(X,Y,Z, offset,1,1,1, 1, 0.5);
% carpettext(X,Y,Z, offset, 22, 0.4, "L/D", -.75, 0.1);
% carpettext(X,Y,Z, offset, 28, 0.35, "SFC", 0.0, 1);
% ylim([0 2.5e4])
% ylabel('MTOW')



% L/D is way more important than SFC




