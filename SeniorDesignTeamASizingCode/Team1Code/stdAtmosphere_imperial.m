% Standard Atmosphere Calculator, British Units - ISO 2533:1975
% Peter Kim
function [density, pressure, temperature] = stdAtmosphere_imperial (height_ft, delta_temp_K)
% density [slug/ft^3]
% pressure [lbf/ft^2]
% temperature [Kelvin]
Hp = height_ft;
    if height_ft <= 36089.2
        A = 288.15;
        B = -1.9812e-3;
        temperature = A + B*Hp;     
        
        C = 4.2927085;
        D = -29.514885e-6;
        E = 5.2558797;
        pressure = (C+D*Hp)^E;      

        I = 0.24179285;
        J = -1.6624675e-6;
        L = 4.2558797;
        density = (I+J*Hp)^L;       
        density = density/(1+delta_temp_K/temperature);

    elseif height_ft <= 65616.8
        temperature = 216.65;

        F = 2678.442;
        G = -48.063462e-6;
        pressure = F^(G*Hp);

        M = 4.0012122e-3;
        N = -48.063462e-6;
        density = M^(N*Hp);
        density = density/(1+delta_temp_K/temperature);

    elseif height_ft <=104987
        A = 196.65;
        B = 0.3048e-3;
        temperature = A + B*Hp;     
        
        C = 0.79011202;
        D = 1.2246435e-6;
        E = -34.163218;
        pressure = (C+D*Hp)^E;      

        I = 1.1616564;
        J = 1.8005232e-6;
        L = -35.163218;
        density = (I+J*Hp)^L;       
        density = density/(1+delta_temp_K/temperature);
    else
        warning("Sorry I haven't finished it yet")
    end
end