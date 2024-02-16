function [W_Scruisetakeoff,W_Pcruisetakeoff1,P_Wcruisetakeoff1] ... 
    = constraintDiagramFunction(plot2scale,cruisealt,takeoffalt,cruisev,...
    runway_length,dh_dt,L_D,Clmax,CD0,eta)

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

% % W/P Plot
% h = figure;
% set(h, 'Resize', 'off');
% plot(W_S, W_Ptakeoff, 'r', 'LineWidth', 2);
% hold on;
% xline(W_Sland, 'm', 'LineWidth', 2);
% plot(W_S, W_Pclimb, 'g', 'LineWidth', 2);
% plot(W_S, W_Pcruise, '-b', 'LineWidth', 2);
% plot(W_S(W_Pcruisetakeoffindex1),W_Pcruise(W_Pcruisetakeoffindex1),'o','MarkerSize', 10,'MarkerFaceColor','k');
% hatchedline(W_S(5:W_Smaxindex),W_Ptakeoff(5:W_Smaxindex),'-r',-90*pi/180,ymax1/xmax,-0.02*xmax/100,1);
% hatchedline(W_Slandvect, W_Pline, '-m', 90*pi/180,ymax1/xmax, -0.02*xmax/100, 1);
% hatchedline(W_S(5:W_Smaxindex),W_Pclimb(5:W_Smaxindex),'-g',-90*pi/180,ymax1/xmax,-0.02*xmax/100,1);
% hatchedline(W_S(5:W_Smaxindex),W_Pcruise(5:W_Smaxindex),'-b',-90*pi/180,ymax1/xmax,-0.02*xmax/100,1);
% ylim([0,ymax1])
% xlim([0,xmax])
% set(gca, 'FontName', 'Calibri');
% set(gca, 'FontSize', 12); 
% ylabel('Power Loading $W_P$ $\left(\frac{lbs}{hp}\right)$', 'Interpreter', 'latex', 'FontSize', 14, 'FontName', 'Calibri');
% xlabel('Wing Loading $W_S$ $\left(\frac{lbs}{ft^2}\right)$', 'Interpreter', 'latex', 'FontSize', 14, 'FontName', 'Calibri');
% set(gcf,'color','w');
% grid on;
% legend(sprintf('Takeoff Requirement \nat %d feet', takeoffalt), ...
%        sprintf('Landing Requirement \nto Return Immediately'), ...
%        sprintf('Climb Requirement \nfor %.2f Gradient', CGR), ...
%        sprintf('Cruise Requirement \nat %d feet', cruisealt), ...
%        sprintf('Intersection of Cruise & \nTakeoff Requirements'), ... 
%        'Location', 'northeastoutside', 'FontSize', 14);
% uistack(findobj(gca, 'Type', 'line', 'Marker', 'o'), 'top');
% set(h, 'Position', [0, 0, 720, 300]);
% annotation('textbox', [0.69, 0.25, 0.25, 0.05], 'String', ...
%     sprintf(['Wing Loading =  %.2f lbs/ft^2 \nPower to Weight =  %.2f hp/lbs'], ...
%     W_S(W_Pcruisetakeoffindex1), W_Pcruisetakeoff1), ...
%     'HorizontalAlignment', 'right', 'FontSize', 12, 'Color', 'black', 'FitBoxToText', 'on', 'FontName', 'Calibri'); 

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

% P/W Plot
h = figure;
set(h, 'Resize', 'off');
plot(W_S, P_Wtakeoff, 'r', 'LineWidth', 2);
hold on;
xline(W_Sland, 'm', 'LineWidth', 2);
plot(W_S, P_Wclimb, 'g', 'LineWidth', 2);
plot(W_S, P_Wcruise, '-b', 'LineWidth', 2);
plot(W_S(P_Wcruisetakeoffindex1),P_Wcruise(P_Wcruisetakeoffindex1),'o','MarkerSize', 10,'MarkerFaceColor','k');
hatchedline(W_S(5:W_Smaxindex),P_Wtakeoff(5:W_Smaxindex),'-r',90*pi/180,.07/xmax,-0.02*xmax/100,1);
hatchedline(W_Slandvect, W_Pline, '-m', 90*pi/180,.07/xmax,-0.02*xmax/100,1);
hatchedline(W_S(5:W_Smaxindex),P_Wclimb(5:W_Smaxindex),'-g',90*pi/180,.07/xmax,-0.02*xmax/100,1);
hatchedline(W_S(5:W_Smaxindex),P_Wcruise(5:W_Smaxindex),'-b',90*pi/180,.07/xmax,-0.02*xmax/100,1);
ylim([0,ymax2])
xlim([0,xmax])
set(gca,'FontName', 'Calibri');
set(gca,'FontSize', 12); 
ylabel('Power to Weight $P_W$ $\left(\frac{hp}{lbs}\right)$', 'Interpreter', 'latex', 'FontSize', 14, 'FontName', 'Calibri');
xlabel('Wing Loading $W_S$ $\left(\frac{lbs}{ft^2}\right)$', 'Interpreter', 'latex', 'FontSize', 14, 'FontName', 'Calibri');
set(gcf,'color','w');
grid on;
legend(sprintf('Takeoff Requirement \nat %d feet', takeoffalt), ...
       sprintf('Landing Requirement \nto Return Immediately'), ...
       sprintf('Climb Requirement \nfor %.2f Gradient', CGR), ...
       sprintf('Cruise Requirement \nat %d feet', cruisealt), ...
       sprintf('Intersection of Cruise & \nTakeoff Requirements'), ... 
       'Location', 'northeastoutside', 'FontSize', 14);
uistack(findobj(gca, 'Type', 'line', 'Marker', 'o'), 'top');
set(h, 'Position', [1000, 0, 720, 300]);
annotation('textbox', [0.69, 0.25, 0.25, 0.05], 'String', ...
    sprintf(['Wing Loading =  %.2f lbs/ft^2 \nPower to Weight =  %.3f hp/lbs'], ...
    W_S(P_Wcruisetakeoffindex1), P_Wcruisetakeoff1), ...
    'HorizontalAlignment', 'right', 'FontSize', 12, 'Color', 'black', 'FitBoxToText', 'on', 'FontName', 'Calibri'); 

end

