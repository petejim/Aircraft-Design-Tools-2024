function [altitude] = equivalent_std_density_alt_finder(density)
% By. Peter Kim
% This code takes in a density of air and finds the std atmosphere altitude with a matching density
% TODO: add offset temperature 
% Assumption
%   altitude will not exceed 20,000 ft. Calculations

% Input
%   density = [density_value] [slug/ft^3]
% Output
%   altitude = [altitude] [ft]

% ISO 2533:1975
% 0 to 36089.2 [ft]
        I = 0.24179285;
        J = -1.6624675e-6;
        L = 4.2558797;

        altitude = (density^(1/L) - I)/J;
end

