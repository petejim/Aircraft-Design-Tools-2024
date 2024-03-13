function [CL, CD] = cruise_climb_CL_CD_finder(sectors, sector_num, AP, AS)
% Conversions
knots_fts = 1.6878098571;

% CL & CD
        CL = sectors(sector_num,8);
        k = AP(4);
        CD0 = AP(5);
        if CL == 0
% AS [ time(sec), distance(nm), weight(lbf), altitude(ft), airspeed(knots), ground speed(knots), power(hp), sfc, CL, CD, mode_#]
            altitude = AS(end,4);   % [ft]
            weight = AS(end,3);     % [lbf]
            S = AP(1);              % [ft^2]
            velocity = sectors(sector_num,4) * knots_fts;   % [ft/s]
            density = stdAtmosphere_imperial(altitude,0);   % [slugs/ft^3]
            CL = 2 * weight / (density * velocity^2 * S);
        elseif CL == 1
            CL = sqrt(CD0/k);
            disp("      Max L/D CL calculated to be: " + CL)
        else
            disp("Input either 0 CL for automatic CL determination or 1 for max L/D CL")
        end
        CD = CD0 + k*(CL^2);
end