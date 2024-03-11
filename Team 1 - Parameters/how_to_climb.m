% How to Climb
close all; clear; clc;

shaft_power = 345;  % [hp]
propeller_efficiency = .8; 
power_output = shaft_power * propeller_efficiency;  % [hp]
W = 10200;          % [lbf] takeoff weight
S = 220;            % [ft^2] wing area
k = 0.01326;
CD0 = 0.017;
rho = 0.00224114;   % [slugs/ft^3]

test_v = linspace(75,300);
climb_angle = zeros(size(test_v));
CL = nan(length(test_v),1);
CD = CL;
D = CL;
T = CL;
for i = 1:length(test_v)
    v = test_v(i);
    CL(i) = (2*W)/(rho*S*(v)^2);
    CD(i) = CD0 + k*(CL(i)^2); %from drag polar given
    D(i) = .5 * rho * v^2 * CD(i) * S;
    climb_angle(i) = asind( ((power_output)/(v*W))- (D(i)/W) );     % [degrees]

    T(i) = power_output*550/v;
end

% plot(test_v,climb_angle)

figure()
plot(D)
hold on
plot(T)