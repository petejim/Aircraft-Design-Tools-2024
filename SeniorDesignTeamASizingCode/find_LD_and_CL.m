function [CL1,LD1] = find_LD_and_CL(veloc,density,WS,AR,osw,CD0)
% Finds the CL and LD of plane at a given flight condition. Based on the
% simple drag polar
    Vfts = veloc * 1.68780986;

    CL1 = WS * 2 / (density * Vfts^2);

    LD1 = CL1 / (CD0 + 1/(pi * osw * AR) * CL1^2);
end