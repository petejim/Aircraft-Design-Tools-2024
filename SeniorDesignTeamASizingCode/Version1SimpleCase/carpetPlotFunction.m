function [W_toval, W_eval, W_fval] = carpetPlotFunction(plotCarpet,carpetscale,LDval,SFCval,EWFval,eta,LDmin,LDmax,SFCmin,SFCmax,EWFmin,EWFmax, ...
    W_pl,R,wind,v,constraintscale,horsepower,inputVariables)
% Generates carpet plots of LoD and BSFC, LoD and EWF, and BSFC and EWF vs.
% MTOW using Breguet Range Equation

% Display Position Variables
scale = 14;
screenSize = get(0, 'ScreenSize');
horOffset = screenSize(3)/100;
vertOffset = screenSize(4)/25;

normalizedPosition1 = [horOffset, screenSize(4)/2, screenSize(3)/3 - 2*horOffset, screenSize(4)/2 - 2*vertOffset];
normalizedPosition2 = [screenSize(3)/3 + horOffset, screenSize(4)/2, screenSize(3)/3 - 2*horOffset, screenSize(4)/2 - 2*vertOffset];
normalizedPosition3 = [2*screenSize(3)/3 + horOffset, screenSize(4)/2, screenSize(3)/3 - 2*horOffset, screenSize(4)/2 - 2*vertOffset];

updateButtonPosition = [0, 0, normalizedPosition1(3)/2-horOffset/10, normalizedPosition1(4)/10];
saveFunctionPosition = [normalizedPosition1(3)/2, 0, normalizedPosition1(3)/2-horOffset/10, normalizedPosition1(4)/10];

saveFigurePosition1 = [screenSize(3)-screenSize(3)/4,screenSize(4)/2,screenSize(3)/4,screenSize(4)/7];

% Define Variables
LD = linspace(LDmin,LDmax,6);
SFC = linspace(SFCmin,SFCmax,6);
EWF = linspace(EWFmin,EWFmax,6);
R = R*((v-wind)/v);

W_to_i = 10000; % takeoff weight initial guess, in lbs
[W_toval, W_eval, W_fval] = sizing1(LDval, SFCval, EWFval, W_pl, R, eta);

% Display Carpet Plots Axis
figDisplay = figure('Position', normalizedPosition3, 'Toolbar', 'none', 'Menubar', 'none');
set(figDisplay, 'Resize', 'off');
set(figDisplay,'NumberTitle', 'off');
title('Plot Settings', 'FontName', 'Calibri Bold', 'FontSize', 16);
text(0, (scale-1)/scale, sprintf('Carpet Plot Axis: %.0f', carpetscale), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-2)/scale, sprintf('Constraint Diagram Axis: %.3f', constraintscale), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');

% Edit Plot Axis
buttonPosition1 = [normalizedPosition1(3)/12, 10*normalizedPosition1(4)/scale, normalizedPosition1(3)/4, normalizedPosition1(4)/scale];
buttonPosition2 = [normalizedPosition1(3)/4, 10*normalizedPosition1(4)/scale, normalizedPosition1(3)/3, normalizedPosition1(4)/scale];
buttonPosition3 = [3*normalizedPosition1(3)/5, 10.25*normalizedPosition1(4)/scale, normalizedPosition1(3)/4, normalizedPosition1(4)/(1.5*scale)];

labelText = uicontrol('Style', 'text', 'String', 'Edit Axis:', 'Position', buttonPosition1, ...
    'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 12);
axisNames = {'Carpet Plot', 'Constraint Diagram'};
axisMenu = uicontrol(figDisplay, 'Style', 'popupmenu', 'String', axisNames, 'Position', buttonPosition2, ...
    'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 12);
txtBox = uicontrol('Style', 'edit', 'Position', buttonPosition3, 'FontName', 'Calibri', 'FontSize', 12);
axis off;

updatebtn = uicontrol('Style', 'pushbutton', 'String', 'Update Figures', ...
    'Position', updateButtonPosition, 'Callback', @clearAllFigures, ...
    'FontName', 'Calibri', 'FontSize', 14); 
savebtn = uicontrol('Style', 'pushbutton', 'String', 'Save Figures', ...
    'Position', saveFunctionPosition, 'Callback', @saveAllFiguresAsSVG, ...
    'FontName', 'Calibri', 'FontSize', 14); 

% Display Carpet Plots
text(0, (scale-4)/scale, sprintf('Carpet Plot 1'), 'FontName', 'Calibri Bold', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-5)/scale, sprintf('   Variable 1: '), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-6)/scale, sprintf('   Variable 2: '), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-7)/scale, sprintf('Carpet Plot 2'), 'FontName', 'Calibri Bold', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-8)/scale, sprintf('   Variable 1: '), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-9)/scale, sprintf('   Variable 2: '), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');

% % Edit Carpet Plots
% buttonPosition4 = [normalizedPosition1(3)/12, 5*normalizedPosition1(4)/scale, normalizedPosition1(3)/4, normalizedPosition1(4)/scale];
% buttonPosition5 = [normalizedPosition1(3)/4, 5*normalizedPosition1(4)/scale, normalizedPosition1(3)/3, normalizedPosition1(4)/scale];
% 
% labelText = uicontrol('Style', 'text', 'String', 'Edit Axis:', 'Position', buttonPosition1, ...
%     'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 12);
% axisNames = {'Carpet Plot', 'Constraint Diagram'};
% axisMenu = uicontrol(fig, 'Style', 'popupmenu', 'String', axisNames, 'Position', buttonPosition2, ...
%     'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 12);
% txtBox = uicontrol('Style', 'edit', 'Position', buttonPosition3, 'FontName', 'Calibri', 'FontSize', 12);
% axis off;

%% FUNCTIONS

% Save Plots
function saveAllFiguresAsSVG(~,~)  
    uploadNewSave;

    % Create New Save
    function uploadNewSave(~,~)
        % Get all open figures
        figHandles = findall(0, 'Type', 'figure');
        

    % Check if there are any figures to save
    if isempty(figHandles)
        % Display a message that no figures were produced
        close all; 
        fig = figure('Position', saveFigurePosition1, 'Toolbar', 'none', 'Menubar', 'none');
        set(fig, 'Resize', 'off');
        set(fig,'NumberTitle', 'off');
        uicontrol('Style', 'text', 'String', 'No figures to save!', 'Position', ...
        [0, 2*saveFigurePosition1(4)/5, saveFigurePosition1(3), saveFigurePosition1(4)/4], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 16);
        okButton = uicontrol('Style', 'pushbutton', 'String', 'OK', ...
        'Position', [0,0,saveFigurePosition1(3)/2,saveFigurePosition1(4)/4], 'Callback', @mainMenu, ...
        'FontName', 'Calibri', 'FontSize', 16);
        return;
    end

    % Get the path of the currently executing script
    scriptPath = fullfile(fileparts(mfilename('fullpath')), 'SavedData');

    % Create a folder within the "SavedData" folder
    saveFolderName = ['SavedFigures_', datestr(now, 'yyyy-mm-dd_HH-MM-SS')];
    savedDataFolder = fullfile(scriptPath, saveFolderName);
    if ~exist(savedDataFolder, 'dir')
        mkdir(savedDataFolder);
    end

    % Iterate through each figure and save as SVG
    for i = 1:length(figHandles)
        figHandle = figHandles(i);
        
        % Save the figure as an SVG file inside the folder
        figureFileName = fullfile(savedDataFolder, ['figure_', num2str(figHandle.Number), '.svg']);
        saveas(figHandle, figureFileName, 'svg');
    end

    % Display that the data was saved
    close all; 
    fig = figure('Position', saveFigurePosition1, 'Toolbar', 'none', 'Menubar', 'none');
    set(fig, 'Resize', 'off');
    set(fig,'NumberTitle', 'off');
    uicontrol('Style', 'text', 'String', 'Your figures were saved to the Saved Data folder!', 'Position', ...
    [0, 2*saveFigurePosition1(4)/5, saveFigurePosition1(3), saveFigurePosition1(4)/4], ...
    'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 16);
    newSaveButton = uicontrol('Style', 'pushbutton', 'String', 'OK', ...
    'Position', [0,0,saveFigurePosition1(3)/2,saveFigurePosition1(4)/4], 'Callback', @mainMenu, ...
    'FontName', 'Calibri', 'FontSize', 16);

    function mainMenu(~,~)
        close all; % Close all open figures
        SizingToolInputs(1,horsepower,inputVariables);
    end
end

end

if plotCarpet == 1
%% Plots

    %% Figure 1: L/D & SFC
    
    for (i = 1:length(LD))
        for j = 1:length(SFC)
             [W_to(i,j,:), W_e(i,j,:), W_f(i,j,:)] = sizing1(LD(i), SFC(j), EWFval, W_pl, R, eta);
        end
    end
    
    [X, Y] = meshgrid(LD, SFC);
    offset = LD(4)*SFC(4);
    
    Z = reshape(W_to(:,:,1), [length(LD), length(SFC)]);
    Z = Z';
    % disp(X)
    % disp(Y)
    % disp(Z)
    % disp(offset)
    carpet(X, Y, Z, offset, 0, 'r', 'b', 'LineWidth', 2);
    carpetlabel(X, Y, Z, offset, 0, -1, 1, 0, 0, 'FontSize', 10);
    
    ylim([0 carpetscale]);
    set(gca, 'Box', 'on', 'LineWidth', 2, 'Color', 'none', 'XColor', 'black', 'YColor', 'black');
    ylabel('Maximum Takeoff Weight');
    grid minor;
    set(gcf, 'color', 'w');
    set(gcf,'NumberTitle', 'off');
    set(gca, 'FontName', 'Calibri');
    set(gca, 'FontSize', 12);
    set(gcf, 'Position', normalizedPosition1);
    set(gcf, 'ToolBar', 'none', 'MenuBar', 'none');
    
    % Edit Axis
    xLimits = get(gca, 'XLim');
    xDif = xLimits(2)-xLimits(1);
    xLimits(2) = xLimits(2)+xDif/8;
    xLimits(1) = xLimits(1)-xDif/8;
    xlim([xLimits(1),xLimits(2)]);
    text(mean(xLimits), -carpetscale/20, ['Empty Weight Fraction: ', num2str(EWFval)], ...
        'FontSize', 16, 'FontName', 'Calibri', 'HorizontalAlignment', 'center');
    
    %% Figure 2: L/D & EWF
    
    for (i = 1:length(LD))
        for j = 1:length(EWF)
             [W_to(i,:,j), W_e(i,:,j), W_f(i,:,j)] = sizing1(LD(i), SFCval, EWF(j), W_pl, R, eta);
        end
    end
    
    [X,Y] = meshgrid(LD,EWF);
    offset = 5*LD(4)*EWF(4);
    Z = reshape(W_to(:,1,:),[length(LD),length(EWF)]);
    Z = Z';
    h_p = carpet(X,Y,Z,offset,0,'#0B6623','b','LineWidth',2);
    h = carpetlabel(X, Y, Z, offset, 0, -1, 1, 0, 0,'FontSize', 12);
    carpettext(X,Y,Z, offset, 0, 0, "L/D", 0, 0);
    carpettext(X,Y,Z, offset, 0, 0, "EWF", 0, 0);
    
    ylim([0 carpetscale]);
    set(gca, 'Box', 'on', 'LineWidth', 2, 'Color', 'none', 'XColor', 'black', 'YColor', 'black');
    ylabel('Maximum Takeoff Weight');
    grid minor
    set(gcf,'color','w');
    set(gcf,'NumberTitle', 'off');
    set(gca,'FontName', 'Calibri');
    set(gca,'FontSize', 12); 
    set(gcf, 'Position', normalizedPosition2); 
    set(gcf, 'ToolBar', 'none', 'MenuBar', 'none');
    
    % Edit Axis
    xLimits = get(gca, 'XLim');
    xDif = xLimits(2)-xLimits(1);
    xLimits(2) = xLimits(2)+xDif/8;
    xLimits(1) = xLimits(1)-xDif/8;
    xlim([xLimits(1),xLimits(2)]);
    text(mean(xLimits), -carpetscale/20, ['Specific Fuel Consumption: ', num2str(SFCval)], ...
        'FontSize', 16, 'FontName', 'Calibri', 'HorizontalAlignment', 'center');
    
    % %% Figure 3: SFC & EWF
    % 
    % for (i = 1:length(SFC))
    %     for j = 1:length(EWF)
    %          [W_to(:,i,j), W_e(:,i,j), W_f(:,i,j)] = sizing1(LDval, SFC(i), EWF(j), W_pl, R, eta);
    %     end
    % end
    % 
    % [X,Y] = meshgrid(SFC,EWF);
    % offset = SFC(4)*EWF(4);
    % Z = reshape(W_to(1,:,:),[length(SFC),length(EWF)]);
    % Z = Z';
    % h_p = carpet(X,Y,Z,offset,0,'#0B6623','r','LineWidth',2);
    % h = carpetlabel(X, Y, Z, offset, 0, -1, -1, 0, 0,'FontSize', 12);
    % 
    % carpettext(X,Y,Z, offset, 0, 0, "SFC", 0, 0);
    % carpettext(X,Y,Z, offset, 0, 0, "EWF", 0, 0);
    % 
    % ylim([0 carpetscale]);
    % set(gca, 'Box', 'on', 'LineWidth', 2, 'Color', 'none', 'XColor', 'black', 'YColor', 'black');
    % ylabel('Maximum Takeoff Weight');
    % grid minor
    % set(gcf,'color','w');
    % set(gcf,'NumberTitle', 'off');
    % set(gca,'FontName', 'Calibri');
    % set(gca,'FontSize', 12); 
    % set(gcf, 'Position', normalizedPosition3); 
    % set(gcf, 'ToolBar', 'none', 'MenuBar', 'none');
    % 
    % % Edit Axis
    % xLimits = get(gca, 'XLim');
    % xDif = xLimits(2)-xLimits(1);
    % xLimits(2) = xLimits(2)+xDif/10;
    % xLimits(1) = xLimits(1)-xDif/10;
    % text(mean(xLimits), -carpetscale/20, ['Lift to Drag Ratio: ', num2str(LDval)], ...
    %     'FontSize', 16, 'FontName', 'Calibri', 'HorizontalAlignment', 'center');

end 

    %% Sizing Function
    
    function [W_to, W_e, W_f] = sizing1(LD, SFC, EWF, W_pl, R, eta)
    W_to = 10000;
    error = 10;
    
    while (abs(error) >= 1)
        W_e = EWF .* W_to;
        W_f_1 = W_to - W_e - W_pl;
        W_f_2 = W_to-(W_to./(exp((R.*6076.12).*(SFC/550/3600)./(eta*LD))));
        error = W_f_1 - W_f_2;
        W_to = W_to - error;
    end
    
    W_f = W_to - W_pl - W_e;
    
    end
    
    % Callback function to clear all figures
    function clearAllFigures(~, ~)
        close all; % Close all open figures
    end
    
    function mainMenu(~,~)
        close all; % Close all open figures
        SizingToolInputs(1,horsepower,inputVariables);
    end


end