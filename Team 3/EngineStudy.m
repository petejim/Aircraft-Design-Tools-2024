clear
close all
clc

% Engine Code Team 3

% Analyzes Team 2's powerplant configuration with 2x CD-135
% Compares against mission profile

AircraftState = load('Aircraft_State.mat'); % Performance data
AircraftState = AircraftState.AS;
n = length(AircraftState(:,4));
Hp_CD135 = 135;
MaxBHP = Hp_CD135 * 2; % 2x CD135 assuming both on for climb
MinSFC = .35;
EngineType = 'D';
ServiceCeiling = 0; % Non-turbo
MTOW = 9077; % lbs

% Retrieve aircraft state
Power_req_climb = AircraftState(:,7);
Performance_alt = AircraftState(:,4);
Performance_Dist = AircraftState(:,2);
Performance_Weight = AircraftState(:,3);
SFC = AircraftState(:,8);

for i = 1:length(Performance_Weight)
Spec_range(i) = Performance_Dist(i) / (MTOW-Performance_Weight(i));
end

Range = Spec_range*5272;

% Retrieve available powers
[SeaLevelMatrix] = BuildEngineDeck(EngineType, MinSFC, MaxBHP, n);

for k = 1:length(Performance_alt)

    [AdjEngineDeck] = ChangeEngineAlt(EngineType, SeaLevelMatrix, MinSFC, Performance_alt(k), ServiceCeiling, n);
    Power_available(k) = max(AdjEngineDeck(:,1));
    
    
end

figure(1)
subplot(1,2,1)
hold on
plot(Performance_Dist,Power_req_climb,'b','LineWidth', 2)
yline(max(Power_req_climb), '--', 'Horsepower Required for Full Throttle Climb = 219 Hp', 'FontSize', 15, 'LineWidth', 1.5);
%yline(150, '--', 'Horsepower Required for Initial Climb Out = 150 Hp', 'FontSize', 15, 'LineWidth', 1.5);
ax = gca;
ax.XAxis.Exponent = 0;
ax.YAxis(1).Exponent = 0;
grid on
title('Takeoff and Initial Climb','FontSize', 15)
plot(Performance_Dist,Power_available,'r','LineWidth', 2)
xlim([0,114])
xlabel('Distance [Nautical Miles] ','FontSize', 16)
ylabel('Power [Hp] ','FontSize', 16)
subplot(1,2,2)
hold on
plot(Performance_Dist,Power_available,'r','LineWidth', 2)
plot(Performance_Dist,Power_req_climb,'b','LineWidth', 2)
xlim([0,max(Performance_Dist)])
title('Cruise','FontSize', 15)
xlabel('Distance [Nautical Miles] ','FontSize', 16)
ylabel('Power [Hp] ','FontSize', 16)
grid on
ax = gca;
ax.XAxis.Exponent = 0;
ax.YAxis(1).Exponent = 0;




