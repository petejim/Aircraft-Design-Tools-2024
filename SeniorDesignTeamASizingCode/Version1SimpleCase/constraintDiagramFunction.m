function [W_Sval,W_Pval,P_Wval,minhp] ... 
    = constDiagramFunction(plotConstraint,plot2scale,cruisealt,takeoffalt,cruisev,...
    runway_length,dh_dt,L_D,Clmax,CD0,eta,horsepower,W_toval)

% Display Position Variables
screenSize = get(0, 'ScreenSize');
horOffset = screenSize(3)/100;
vertOffset = screenSize(4)/25;
normalizedPosition = [screenSize(3)/2+horOffset, vertOffset, screenSize(3)/2 - 2*horOffset, 5*screenSize(4)/11 - 2*vertOffset];

if horsepower ~= 0
    % P_W for horsepower
    P_Whorsepower = horsepower/W_toval;
end

% Power Loading (in lbs/hp)
plot1scale = 1/plot2scale;
W_Pmaxindex = 21;
W_Pline = linspace(0,plot1scale,W_Pmaxindex);

% Wing Loading (in lbs/ft^2)
W_Smaxindex = 501;
W_S = linspace(0,100,W_Smaxindex);
v = cruisev*1.68781; % Convert to ft/s

% Takeoff Density (in slug/ft^3)
takeoffrhokg = standard_atm(takeoffalt);
takeoffrho = takeoffrhokg * 0.00194032;

% Cruise Density (in kg/m^3)
cruiserho = standard_atm(cruisealt);
cruisesigma = cruiserho/1.225;

% Takeoff Constraint
TOP23 = TOP_function(runway_length); % TOP according to FAR 23, Roskam
TOPnew = TOP23*cruisesigma;
W_Ptakeoff = TOPnew*Clmax./W_S;

% Cruise Constraint
Ip = v*0.681818/170; % Power Index according to Roskam
W_Pcruise = W_S/(cruisesigma*Ip^3);

% Climb Rate
CGRclimb = (dh_dt)/v;
CGRcfr = .04; % According to CFR for long range aircraft
if CGRclimb > CGRcfr
    CGR = CGRclimb;
else
    CGR = CGRcfr;
end

CGRP = (CGR+(L_D)^-1)/(Clmax^(1/2)); % According to FAR 23, Roskam
W_Pclimb = 18.97*eta*cruisesigma^(1/2)./(CGRP*W_S.^(1/2));

% Landing Constraint
vland = sqrt(runway_length/.5136); % According to FAR 23, Roskam in knots
W_Sland = .5*Clmax*takeoffrho*vland^2;
W_Slandvect(1:W_Pmaxindex) = W_Sland;

% Plot Graphics
ymax1 = plot1scale;
xmax = W_Sland+10;

% Find Intersection Points
i = 0;
for i = 1:length(W_S)
    if W_Pcruise(i) >= W_Ptakeoff(i)
        W_Pcruisetakeoffindex1 = i;
        break
    end
    i = i+1;
end
W_Pcruisetakeoff1 = W_Pcruise(W_Pcruisetakeoffindex1);
minhp = W_toval/W_Pcruisetakeoff1;

% Convert to P/W
P_Wtakeoff = 1./W_Ptakeoff;
P_Wclimb = 1./W_Pclimb;
P_Wcruise = 1./W_Pcruise;

% Plot Graphics
ymax2 = plot2scale;
W_Pline = linspace(0,ymax2,W_Pmaxindex);

% Find Intersection Points
i = 0;
for i = 1:length(W_S)
    if P_Wcruise(i) <= P_Wtakeoff(i)
        P_Wcruisetakeoffindex1 = i;
        break
    end
    i = i+1;
end
P_Wcruisetakeoff1 = P_Wcruise(P_Wcruisetakeoffindex1);
W_Scruisetakeoff = W_S(P_Wcruisetakeoffindex1);
W_Sval = W_S(P_Wcruisetakeoffindex1);
P_Wval = P_Wcruise(P_Wcruisetakeoffindex1);

if plotConstraint == 1
%% Plot Function
% P/W Plot
fig4 = figure;
set(fig4, 'Resize', 'off');
set(fig4,'NumberTitle', 'off');
plot(W_S, P_Wtakeoff, 'r', 'LineWidth', 2);
hold on;
xline(W_Sland, 'm', 'LineWidth', 2);
plot(W_S, P_Wclimb, 'g', 'LineWidth', 2);
plot(W_S, P_Wcruise, '-b', 'LineWidth', 2);

if horsepower == 0 % Plot Minimum Point
    plot(W_S(P_Wcruisetakeoffindex1),P_Wcruise(P_Wcruisetakeoffindex1),'o','MarkerSize', 10,'MarkerFaceColor','k');
    W_Sval = W_S(P_Wcruisetakeoffindex1);
    P_Wval = P_Wcruise(P_Wcruisetakeoffindex1);
end

if horsepower ~= 0 % Plot Hp Line
    P_Whpline = P_Whorsepower.*W_S./W_S;
    plot(W_S,P_Whpline, '--k', 'LineWidth', 2)
    % Find Intersection with Hp and Takeoff Line
    i = 0;
    for i = 1:length(W_S)
        if P_Whpline(i) <= P_Wtakeoff(i)
            P_Whptakeoffindex1 = i;
            break
        end
        i = i+1;
    end
    P_Whptakeoff1 = P_Wtakeoff(P_Whptakeoffindex1);
    W_Shptakeoff = W_S(P_Whptakeoffindex1);
    W_Sval = W_S(P_Whptakeoffindex1);
    P_Wval = P_Wtakeoff(P_Whptakeoffindex1);

    % Find Intersection with Hp and Landing Line
    if W_Shptakeoff >= W_Sland
        W_Sval = W_Sland;
        P_Wval = P_Whorsepower;
    end

    plot(W_Sval,P_Wval,'o','MarkerSize', 10,'MarkerFaceColor','k');
end

hatchedline(W_S(5:W_Smaxindex),P_Wtakeoff(5:W_Smaxindex),'-r',90*pi/180,.07/xmax,-0.02*xmax/100,1);
hatchedline(W_Slandvect, W_Pline, '-m', 90*pi/180,.07/xmax,-0.02*xmax/100,1);
hatchedline(W_S(5:W_Smaxindex),P_Wclimb(5:W_Smaxindex),'-g',90*pi/180,.07/xmax,-0.02*xmax/100,1);
hatchedline(W_S(5:W_Smaxindex),P_Wcruise(5:W_Smaxindex),'-b',90*pi/180,.07/xmax,-0.02*xmax/100,1);
ylim([0,ymax2])
xlim([0,xmax])
set(gca,'FontName', 'Calibri');
set(gca,'FontSize', 12); 
set(gcf, 'ToolBar', 'none', 'MenuBar', 'none');
ylabel('Power to Weight $P_W$ $\left(\frac{hp}{lbs}\right)$', 'Interpreter', 'latex', 'FontSize', 12, 'FontName', 'Calibri');
xlabel('Wing Loading $W_S$ $\left(\frac{lbs}{ft^2}\right)$', 'Interpreter', 'latex', 'FontSize', 12, 'FontName', 'Calibri');
set(gcf,'color','w');
grid on;
legend(sprintf('Takeoff Requirement \nat %d feet with a runway \nlength of %d feet', takeoffalt, runway_length), ...
       sprintf('Landing Requirement \nto Return Immediately'), ...
       sprintf('Climb Requirement \nfor %.2f Gradient', CGR), ...
       sprintf('Cruise Requirement \nat %d feet', cruisealt), ...
       sprintf('Aircraft Configuration'), ... 
       'Location', 'northeastoutside', 'FontSize', 14);
uistack(findobj(gca, 'Type', 'line', 'Marker', 'o'), 'top');
set(fig4, 'Position', normalizedPosition);

annotation('textbox', [0.69, 0.25, 0.25, 0.05], 'String', ...
    sprintf(['Wing Loading =  %.2f lbs/ft^2 \nPower to Weight =  %.3f hp/lbs'], ...
    W_Sval, P_Wval), 'HorizontalAlignment', 'right', 'FontSize', 12, ...
    'Color', 'black', 'FitBoxToText', 'on', 'FontName', 'Calibri');

W_Pval = 1/P_Wval;

end

W_Pval = 1/P_Wval;

end

