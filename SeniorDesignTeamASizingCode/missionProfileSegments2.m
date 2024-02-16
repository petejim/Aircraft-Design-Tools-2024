function [xMission,vMission,wMission,rhoMission,CLMission,LDMission] = ...
    missionProfileSegments(res,plots,bregTypes,MTOW,fFuel,...
    dists,velocs,altitudes,SFCs,WS,EWF,eta,AR,osw,CD0)
%% Description 
% This function is used to display the profile of the mission. You must run
% weightFromSegments first, and then plug the results into this function as
% inputs. The function will return arrays of important variables as a
% function of distance. Don't run this function iteratively unless you need
% to, the performance will be much worse than just running
% weightFromSegments

%% Inputs


%% Outputs

% L/D(x)

% Veloc(x)

% Altitude(x)

%
%% Code

%% Finding Weights at the Start of Each Segment

[~,xSeg,~,~,~,weightSeg] = rangeFromFuelFractions(bregTypes,MTOW,fFuel,...
    dists,velocs,altitudes,SFCs,WS,EWF,eta,AR,osw,CD0);

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
vMission = zeros(length(bregTypes) * res + 1, 1);

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
    [CL1,LD1] = find_LD_and_CL(velocs(i),densitys(i),updWS,AR,osw,CD0);

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
    
                % Distance
                xMission(mVIt,1) = distSgStrt + eta .* LD1 .* ft2nm ./...
                    (sfcConv .* SFCs(i)) .* log(1 ./ (1 - fFuelMatr(:,i)));

                % Density
                rhoMission(mVIt,1) = rho1;

                % CL
                CLMission(mVIt,1) = CL1;

                % L/D
                LDMission(mVIt,1) = LD1;

                % Velocity (ASSUMES CONSTANT DENSITY THROUGHOUT SEGMENT)
                vMission(mVIt,1) = (2 .* wMission(mVIt) ./ ...
                    (densitys(i) * S * CL1)).^0.5 ./ 1.68780986;
    
            % Const L/D, const veloc
            case 1
    
                % Distance
                xMission(mVIt,1) = distSgStrt + eta .* LD1 .* ft2nm ./...
                    (sfcConv .* SFCs(i)) .* log(1 ./ (1 - fFuelMatr(:,i)));

                % Density
                rhoMission(mVIt,1) = 2 .* wMission(mVIt,1) ./ ((velocs(i) * 1.68780986).^ 2 .* S .* CL1);

                % CL
                CLMission(mVIt,1) = CL1;

                % L/D
                LDMission(mVIt,1) = LD1;

                % Velocity
                vMission(mVIt,1) = velocs(i);
    
            % Const veloc, const alt
            case 2
    
                % Distance
                xMission(mVIt,1) = distSgStrt + 2 .* eta .* LDmax .*...
                    ft2nm ./ (sfcConv .* SFCs(i)) .* atan(LD1 .* fFuelMatr(:,i)...
                    ./ (2 .* LDmax .* (1 - k .* CL1 .* LD1 .* fFuelMatr(:,i))));

                % Density
                rhoMission(mVIt,1) = rho1;

                % CL (THIS ONE ASSUMES CONSTANT SEGMENT DENSITY)
                CLMission(mVIt,1) = 2 .* wMission(mVIt,1) ./ ...
                    ((velocs(i) * 1.68780986) .^ 2 .* S .* densitys(i));

                % L/D
                LDMission(mVIt,1) = CLMission(mVIt,1) ./ (CD0 + k .* ...
                    CLMission(mVIt,1) .^ 2);

                % Velocity
                vMission(mVIt,1) = velocs(i);  
            otherwise
    
                error("invalid breguet flag")

        end

    % Increase k by the resolution
    ll = ll + res;
    
end

altMission = altFromDens(rhoMission);

%% Plots
% If editing, make sure to edit both plots as each type is written twice

% Display Stuff
    screenSize = get(0, 'ScreenSize');
    horOffset = screenSize(3)/100;
    vertOffset = screenSize(4)/25;
    normalizedPosition = [horOffset, screenSize(4)/2, 2*screenSize(3)/3 - 2*horOffset, screenSize(4)/2-vertOffset];

if plots(1) == 1

    if length(bregTypes) == 1

        xSegStrt = 0;

    else

        % distance at meeting of each segment
        xSegStrt(i,1) = sum(dists(1:i));

    end
    
    if plots(2) == 1
        % Weight
        fig = figure;
        set(fig, 'Resize', 'off');
        set(fig,'NumberTitle', 'off');
        set(fig, 'Position', normalizedPosition);       
        set(gcf,'color','w');
        grid on;
        set(gca,'FontName', 'Calibri');
        set(gca,'FontSize', 12); 
        set(gcf, 'ToolBar', 'none', 'MenuBar', 'none');

        subplot(2,3,1)
        plot(xMission,wMission)
        xlabel("Distance [nm]",'FontSize', 12, 'FontName', 'Calibri')
        ylabel("Weight [lbs]",'FontSize', 12, 'FontName', 'Calibri')
        
        xlim([0,sum(dists)])
        ylim([0,MTOW])
        xlinecond(xSegStrt, '--r')
        grid on
        
        % Density
        subplot(2,3,2)
        plot(xMission,rhoMission)
        xlabel("Distance [nm]",'FontSize', 12, 'FontName', 'Calibri')
        ylabel("Density [sl/ft^3]", 'FontSize', 12, 'FontName', 'Calibri')
        xlim([0,sum(dists)])
        xlinecond(xSegStrt, '--r');
        grid on
        
        % CL
        subplot(2,3,3)
        plot(xMission,CLMission)
        xlabel("Distance [nm]", 'FontSize', 12, 'FontName', 'Calibri')
        ylabel("CL",'FontSize', 12, 'FontName', 'Calibri')
        xlim([0,sum(dists)])
        xlinecond(xSegStrt, '--r');
        grid on
        
        % L/D
        subplot(2,3,4)
        plot(xMission,LDMission)
        xlabel("Distance [nm]", 'FontSize', 12, 'FontName', 'Calibri')
        ylabel("L/D", 'FontSize', 12, 'FontName', 'Calibri')
        xlim([0,sum(dists)])
        xlinecond(xSegStrt, '--r');
        grid on

        % Velocity
        subplot(2,3,5)
        plot(xMission,vMission)
        xlabel("Distance [nm]", 'FontSize', 12, 'FontName', 'Calibri')
        ylabel("Velocity [KTAS]", 'FontSize', 12, 'FontName', 'Calibri')
        xlim([0,sum(dists)])
        ylim([0,150])
        xlinecond(xSegStrt, '--r');
        grid on

        % Altitude
        subplot(2,3,6)
        plot(xMission,altMission)
        xlabel("Distance [nm]", 'FontSize', 12, 'FontName', 'Calibri')
        ylabel("Altitude [ft]", 'FontSize', 12, 'FontName', 'Calibri')
        xlim([0,sum(dists)])
        ylim([0,25000])
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
        
        % Density
        figure
        plot(xMission,rhoMission)
        xlabel("Distance [nm]", 'FontName', 'Calibri Bold', 'FontSize', 12)
        ylabel("Density [sl/ft^3]", 'FontName', 'Calibri Bold', 'FontSize', 12)
        xlim([0,sum(dists)])
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
        plot(xMission,vMission)
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
        ylim([0,25000])
        xlinecond(xSegStrt, '--r');
        grid on
    end
end

    function [] = xlinecond(xSegStrt, color)
        
        if xSegStrt ~= 0
            
            xline(xSegStrt, color);

        end

    end
end