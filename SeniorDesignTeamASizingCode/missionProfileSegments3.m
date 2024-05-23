function [xMission,vTASMission,vGrndMission,wMission,rhoMission,CLMission,...
    LDMission,pShaftMission,altMission] = ...
    missionProfileSegments3(res,plots,bregTypes,MTOW,fFuel,...
    dists,veloTAS,vWind,altitudes,SFCs,WS,EWF,eta,AR,osw,CD0)
%% Description 
% This function is used to display the profile of the mission. You must run
% weightFromSegments first, and then plug the results into this function as
% inputs. The function will return arrays of important variables as a
% function of distance. Don't run this function iteratively unless you need
% to, the performance will be much worse than just running
% weightFromSegments

%% Inputs
% res       = num profile points to eval between each segment         [quantity]
% plots     = [a,b] where a is 1 if you want plots, 0 if not          
%           = b is 1 if you want all plots, 0 if you want individual
% bregTypes = vector of breguet types for each segment                []
% MTOW      = maximum takeoff weight                                  [lbs]
% fFuel     = vector of fuel fractions for each segment               [lbs]
% dists     = vector of distances for each segment                    [nm]
% veloTAS   = vector of true airspeeds for each segment               [kts]
% vWind     = vector of windspeeds for each segment                   [kts]
% altitudes = vector of altitudes for each segment                    [ft]
% SFCs      = vector of specific fuel consumptions for each segment   [lbf/hr/hp]
% WS        = wing loadings at beginning                              [lbf/ft^2]
% EWF       = empty  weight fraction                                  []
% eta       = propeller efficiency                                    []
% AR        = aspect                                                  []
% osw       = Oswald efficiency                                       []
% CD0       = parasitic drag coefficient                              []

%% Outputs
% xMission      = vector of distances for each point                  [nm]
% vTASMission   = vector of true airspeeds for each point             [kts]
% vGrndMission  = vector of groundspeeds for each point               [kts]
% wMission      = vector of weights for each point                    [lbs]
% rhoMission    = vector of densities for each point                  [slug/ft^3]
% CLMission     = vector of lift coeffs for each point                [unitless]
% LDMission     = vector of L/D ratios for each point                 [unitless]
% pShaftMission = vector of shaft powers for each point               [hp]



%% Code

%% Finding Weights at the Start of Each Segment

[~,xSeg,~,~,~,weightSeg] = rangeFromFuelFractions(bregTypes,MTOW,fFuel,...
    dists,veloTAS,vWind,altitudes,SFCs,WS,EWF,eta,AR,osw,CD0);

%% Set Up

% Density conversion
densitys = densFromAlt(altitudes);

% Preallocating
fFuelMatr = zeros(res + 1,length(bregTypes));

% Set up fuel fractions to find distance at each point
for i = 1:length(bregTypes)
    
    % Represents the fuel fraction relative to the start of the segment
    fFuelMatr(:,i) = linspace(0,fFuel(i),res + 1)'; 

end

% Preallocate for distances, weight, L/D, density, CL, Velocity
xMission = zeros(length(bregTypes) * res + 1,1);
wMission = zeros(length(bregTypes) * res + 1, 1);
LDMission = zeros(length(bregTypes) * res + 1, 1);
rhoMission = zeros(length(bregTypes) * res + 1, 1);
CLMission = zeros(length(bregTypes) * res + 1, 1);
vTASMission = zeros(length(bregTypes) * res + 1, 1);
vGrndMission = zeros(length(bregTypes) * res + 1, 1);

% Iterator for the mission profile vectors
ll = 1;

%% Conversions

% Conversion to change feet to nautical miles
ft2nm = 12 * 2.54 / 100 / 1852;

% Conversion to change lbf/hr/hp to lbf/s/(lbf ft/s)
sfcConv = 1 / 3600 / 550;

% Induced drag coefficient
k = 1/(pi * osw * AR);

% Wing area
S = MTOW / WS;



%% Loops

% Iterate through the missions
for i = 1:length(bregTypes)
    
    % Mission vector iterator vector(puts stuff in correct place)
    mVIt = ll:ll+res;
    
    % Wingloading at the beginning of the segment
    updWS = weightSeg(i) / (S);
    % This function is the same that the weightFromSegments code uses
    [CL1,LD1] = find_LD_and_CL(veloTAS(i),densitys(i),updWS,AR,osw,CD0);

    % I rewrote this one using Dr. Iscold's poster
    LDmax = sqrt(CD0/k)/2/CD0;

    % Distance up to start of segment
    distSgStrt = sum(xSeg(1:(i-1)));

    % proportion of fuel consumed up to the start of the segment
    prpFuelStrt = prod(1-fFuel(1:(i-1)));

    % Initial segment density
    rho1 = densitys(i);

    % Weight at each point
    wMission(mVIt,1) = MTOW .* prpFuelStrt .* (1 - fFuelMatr(:,i));

        switch bregTypes(i)
    
            % Const alt, const L/D
            case 0

                % time from start of segment in hours
                tSS = 2 .* LD1 .* eta .* 550 .* (wMission(mVIt,1).^(-1/2) - ...
                weightSeg(i)^(-1/2)) ./ (SFCs(i) .* ...
                (2./(densitys(i) .* S .* CL1)).^(1/2));

                % Distance
                xMission(mVIt,1) = distSgStrt + eta .* LD1 .* ft2nm ./...
                    (sfcConv .* SFCs(i)) .* log(1 ./ (1 - fFuelMatr(:,i)))...
                    + tSS .* vWind(i);

                % Density
                rhoMission(mVIt,1) = rho1;

                % CL
                CLMission(mVIt,1) = CL1;

                % L/D
                LDMission(mVIt,1) = LD1;

                % Airspeed (ASSUMES CONSTANT DENSITY THROUGHOUT SEGMENT)
                vTASMission(mVIt,1) = (2 .* wMission(mVIt) ./ ...
                    (densitys(i) * S * CL1)).^0.5 ./ 1.68780986;

                % Groundspeed
                vGrndMission(mVIt,1) = vTASMission(mVIt,1) + vWind(i);
    
            % Const L/D, const veloc
            case 1

                % Distance
                xMission(mVIt,1) = distSgStrt + (eta .* LD1 .* ft2nm ./...
                    (sfcConv .* SFCs(i)) .* log(1 ./ (1 - fFuelMatr(:,i))))...
                    .* (1 + vWind(i)/veloTAS(i));

                % Density
                rhoMission(mVIt,1) = 2 .* wMission(mVIt,1) ./ ((veloTAS(i)...
                    * 1.68780986).^ 2 .* S .* CL1);

                % CL
                CLMission(mVIt,1) = CL1;

                % L/D
                LDMission(mVIt,1) = LD1;

                % Airspeed
                vTASMission(mVIt,1) = veloTAS(i);

                % Groundspeed
                vGrndMission(mVIt,1) = veloTAS(i) + vWind(i);
    
            % Const veloc, const alt
            case 2
    
                % Distance
                xMission(mVIt,1) = distSgStrt + (2 .* eta .* LDmax .*...
                    ft2nm ./ (sfcConv .* SFCs(i)) .* atan(LD1 .* fFuelMatr(:,i)...
                    ./ (2 .* LDmax .* (1 - k .* CL1 .* LD1 .* fFuelMatr(:,i)))))...
                    .* (1 + vWind(i)/veloTAS(i));

                % Density
                rhoMission(mVIt,1) = rho1;

                % CL (THIS ONE ASSUMES CONSTANT SEGMENT DENSITY)
                CLMission(mVIt,1) = 2 .* wMission(mVIt,1) ./ ...
                    ((veloTAS(i) * 1.68780986) .^ 2 .* S .* densitys(i));

                % L/D
                LDMission(mVIt,1) = CLMission(mVIt,1) ./ (CD0 + k .* ...
                    CLMission(mVIt,1) .^ 2);

                % Airspeed
                vTASMission(mVIt,1) = veloTAS(i);

                % Groundspeed
                vGrndMission(mVIt,1) = veloTAS(i) + vWind(i);
            otherwise
    
                error("invalid breguet flag")

        end

    % Increase k by the resolution
    ll = ll + res;
    
end

pShaftMission = vTASMission .* 1.68780986 .* wMission ./ (eta .* LDMission .* 550);

altMission = altFromDens(rhoMission);

%% Plots
% If editing, make sure to edit both plots as each type is written twice

% Display Stuff
    screenSize = get(0, 'ScreenSize');
    horOffset = screenSize(3)/100;
    vertOffset = screenSize(4)/25;
    normalizedPosition = [horOffset, screenSize(4)/2, 2*screenSize(3)/3 - 2*horOffset, screenSize(4)/2-vertOffset];


if length(bregTypes) == 1

    xSegStrt = 0;

else
    
    for i = 1:length(bregTypes)-1

        % distance at meeting of each segment
        xSegStrt(i,1) = sum(dists(1:i));

    end

end

if plots(1) == 1
    
    if plots(2) == 1
        % Weight
        fig = figure;
        % set(fig, 'Resize', 'off');
        set(fig,'NumberTitle', 'off');
        set(fig, 'Position', normalizedPosition);       
        set(gcf,'color','w');
        grid on;
        set(gca,'FontName', 'Calibri');
        set(gca,'FontSize', 12); 
        set(gcf, 'ToolBar', 'none', 'MenuBar', 'none');

        subplot(2,3,1)
        plot(xMission,wMission,LineWidth=1.5)
        xlabel("Distance [nm]",'FontSize', 12, 'FontName', 'Calibri')
        ylabel("Weight [lbs]",'FontSize', 12, 'FontName', 'Calibri')
        ax = gca;
        ax.XAxis.Exponent = 0;
        xlim([0,sum(dists)])
        ylim([0,MTOW])
        xlinecond(xSegStrt, '--r')
        grid on
        
        % Groundspeed
        subplot(2,3,2)

        plot(xMission,vGrndMission,LineWidth=1.5)
        xlabel("Distance [nm]")
        ylabel("Groundspeed [kts]")
        ax = gca;
        ax.XAxis.Exponent = 0;

        xlim([0,sum(dists)])
        ylim([0,200])
        xlinecond(xSegStrt, '--r');
        grid on
        
        % CL
        subplot(2,3,3)
        plot(xMission,CLMission,LineWidth=1.5)
        xlabel("Distance [nm]", 'FontSize', 12, 'FontName', 'Calibri')
        ylabel("CL",'FontSize', 12, 'FontName', 'Calibri')
        ax = gca;
        ax.XAxis.Exponent = 0;
        xlim([0,sum(dists)])
        xlinecond(xSegStrt, '--r');
        grid on
        
        % L/D
        subplot(2,3,4)
        plot(xMission,LDMission,LineWidth=1.5)
        xlabel("Distance [nm]", 'FontSize', 12, 'FontName', 'Calibri')
        ylabel("L/D", 'FontSize', 12, 'FontName', 'Calibri')
        ax = gca;
        ax.XAxis.Exponent = 0;
        xlim([0,sum(dists)])
        xlinecond(xSegStrt, '--r');
        grid on

        % Velocity
        subplot(2,3,5)

        plot(xMission,vTASMission,LineWidth=1.5)
        xlabel("Distance [nm]", 'FontSize', 12, 'FontName', 'Calibri')
        ylabel("Velocity [KTAS]", 'FontSize', 12, 'FontName', 'Calibri')
        ax = gca;
        ax.XAxis.Exponent = 0;

%         plot(xMission,vTASMission)
%         xlabel("Distance [nm]")
%         ylabel("Velocity [KTAS]")

        xlim([0,sum(dists)])
        ylim([0,150])
        xlinecond(xSegStrt, '--r');
        grid on

        % Altitude
        subplot(2,3,6)
        plot(xMission,altMission,LineWidth=1.5)
        xlabel("Distance [nm]", 'FontSize', 12, 'FontName', 'Calibri')
        ylabel("Altitude [ft]", 'FontSize', 12, 'FontName', 'Calibri')
        ax = gca;
        ax.XAxis.Exponent = 0;
        ax.YAxis.Exponent = 0;
        xlim([0,sum(dists)])
        ylim([0,35000])
        xlinecond(xSegStrt, '--r');
        grid on

    else

        % Weight
        figure
        plot(xMission,wMission)
        xlabel("Distance [nm]", 'FontName', 'Calibri Bold', 'FontSize', 12)
        ylabel("Weight [lbs]", 'FontName', 'Calibri Bold', 'FontSize', 12)
        xlim([0,sum(dists)])
        ylim([0,MTOW])
        xlinecond(xSegStrt, '--r');
        grid on
        
        % Groundspeed
        figure

        plot(xMission,vGrndMission)
        xlabel("Distance [nm]", 'FontName', 'Calibri Bold', 'FontSize', 12)
        ylabel("Groundspeed [kts]", 'FontName', 'Calibri Bold', 'FontSize', 12)

        xlim([0,sum(dists)])
        ylim([0,150])
        xlinecond(xSegStrt, '--r');
        grid on
        
        % CL
        figure
        plot(xMission,CLMission)
        xlabel("Distance [nm]", 'FontName', 'Calibri Bold', 'FontSize', 12)
        ylabel("CL", 'FontName', 'Calibri Bold', 'FontSize', 12)
        xlim([0,sum(dists)])
        xlinecond(xSegStrt, '--r');
        grid on
        
        % L/D
        figure
        plot(xMission,LDMission)
        xlabel("Distance [nm]", 'FontName', 'Calibri Bold', 'FontSize', 12)
        ylabel("L/D", 'FontName', 'Calibri Bold', 'FontSize', 12)
        xlim([0,sum(dists)])
        xlinecond(xSegStrt, '--r');
        grid on
    
        % Velocity
        figure

        plot(xMission,vTASMission)
        xlabel("Distance [nm]", 'FontName', 'Calibri Bold', 'FontSize', 12)
        ylabel("Velocity [KTAS]", 'FontName', 'Calibri Bold', 'FontSize', 12)

        xlim([0,sum(dists)])
        ylim([0,150])
        xlinecond(xSegStrt, '--r');
        grid on

        % Altitude
        figure
        plot(xMission,altMission)
        xlabel("Distance [nm]", 'FontName', 'Calibri Bold', 'FontSize', 12)
        ylabel("Altitude [ft]", 'FontName', 'Calibri Bold', 'FontSize', 12)
        xlim([0,sum(dists)])
        ylim([0,35000])
        xlinecond(xSegStrt, '--r');
        grid on
    end
end

    function [] = xlinecond(xSegStrt, color)
        
        if xSegStrt(end) ~= 0
            
            xline(xSegStrt, color);

        end

    end
end