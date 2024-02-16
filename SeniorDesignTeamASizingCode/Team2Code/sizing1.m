function [W_to, W_e, W_f] = sizing1(LD, SFC, EWF, W_pl, R, eta,W_to)
% INPUTS:
%   LD - lift drag ratio
%   SFC - specific fuel consumption of supposed engine
%   EWF - empty weight fraction
%   W_pl - payload weight [lbs]
%   R - range [nautical miles]
%   eta propeller efficiency
%   W_to - takeoff weight initial guess

% OUTPUTS:
%   W_to - takeoff weight result [lbs]
%   W_e - empty weight result [lbs]
%   W_f - fuel weight result [lbs]

error = 10;

while (abs(error) >= 1)
    W_e = EWF .* W_to;
    W_f_1 = W_to - W_e - W_pl;
    W_f_2 = W_to - (W_to / (exp((R .* 6076.12) .* (SFC / 550 / 3600) ./ (eta * LD))));
    error = W_f_1 - W_f_2; 
    W_to = W_to - error;
end

W_f = W_to - W_pl - W_e;