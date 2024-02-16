function [Tstd, P, rhostd, rho] = standatm(alt, T, unit)

if unit == "IMP" %Temperature in K, Altitude in Feet

    if 0<=alt && alt<=36089.2

        Tstd = 288.15-1.9812e-3*alt; %K
        P = (4.2927085-29.514885e-6*alt)^5.2558797; %lbf/ft^2
        rhostd = (0.24179285 - 1.6624675e-6*alt)^4.2558797; %slug/ft^3
        rho = rhostd/(1 + ((T - Tstd)/Tstd)); %slug/ft^3

    elseif 36089.2 < alt && alt <= 65616.8

        Tstd = 216.65; %K
        P = 2678.442*exp(-48.063462e-6*alt); %lbf/ft^2
        rhostd = 4.0012122e-3*exp(-48.063462e-6*alt); %slug/ft^3
        rho = rhostd/(1 + ((T - Tstd)/Tstd)); %slug/ft^3

    else

        Tstd = "Error";
        P = "Error";
        rho = "Error";

    end

elseif unit == "MET" %Temperature in K, Altitude in Meters

    if 0 <= alt && alt<=11000

        Tstd = 288.15 - 6.5e-3*alt; %K
        P = (8.9619638-0.20216125e-3*alt)^5.2558797; %N/m^2
        rhostd = (1.04884 - 23.659414e-6*alt)^4.2558797; %kg/m^3
        rho = rhostd/(1 + ((T - Tstd)/T)); %kg/m^3

    elseif 11000<alt && alt<=20000

        Tstd = 216.65; %K
        P = 128244.5*exp(-0.15768852e-3*alt); %N/m^2
        rhostd = 2.06214*exp(-0.15768852e-3*alt); %kg/m^3
        rho = rhostd/(1 + ((T - Tstd)/T)); %kg/m^3

    else

        Tstd = "Error";
        P = "Error";
        rho = "Error";

    end
else

    Tstd = "Error";
    P = "Error";
    rho = "Error";

end