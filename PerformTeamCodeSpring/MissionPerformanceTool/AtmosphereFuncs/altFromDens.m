% Danilo 

function [alts] = altFromDens(densitys)
    %% Description
    
    % Converts density in slug/ft^3 to altitude in ft. Based on ISA. Doesn't
    % work for densities corresponding to altitudes below zero or above 36000 ft.
    
    %% Code
    
    b1 = densFromAlt(0);
    
    b2 = densFromAlt(36000);
    
    % Check if out of bounds
    if any((densitys > (b1 + 0.0001)) | (densitys < (b2-0.0001)))
    
        warning("density out of bounds")
    
    end
    
    
    % First layer
    I = 0.24179285;
    
    J = -1.6624675e-6;
    
    L = 4.2558797;
    
    alts = (densitys.^(1/L) - I) ./ J;
    
    end