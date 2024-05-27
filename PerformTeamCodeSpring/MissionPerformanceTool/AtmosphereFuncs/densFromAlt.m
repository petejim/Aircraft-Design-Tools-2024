function [densitys] = densFromAlt(altitudes)
%% Description
% Takes in altitude in ft and returns density in slug/ft^3
% Works only for altitudes below 36000 ft
% Based on ISA

%% Code

% Check if out of bounds
if any((altitudes > 36000) | (altitudes < 0))

    warning("altitude out of bounds")

end

% First layer
I = 0.24179285;

J = -1.6624675e-6;

L = 4.2558797;

densitys = (I + J .* altitudes) .^ L;

end