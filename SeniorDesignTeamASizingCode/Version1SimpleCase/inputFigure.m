function [inputVariables,horsepower] ...
        = inputFigure(inputVariables,horsepower,carpetscale,constraintscale)
% Input Function Feature

% Set Variables
cruisealt = inputVariables(1);
takeoffalt = inputVariables(2);
cruisev = inputVariables(3);
runway_length = inputVariables(4);
dh_dt = inputVariables(5);
eta = inputVariables(6);
W_pl = inputVariables(7);
Range = inputVariables(8);
wind = inputVariables(9);
LD = inputVariables(10);
SFC = inputVariables(11);
EWF = inputVariables(12);
Clmax = inputVariables(13);
CD0 = inputVariables(14);
carpetscale = inputVariables(15);
constraintscale = inputVariables(16);

% Screen Poisition Variables
screenSize = get(0, 'ScreenSize');
horOffset = screenSize(3)/100;
vertOffset = screenSize(4)/25;
normalizedPosition1 = [horOffset, vertOffset, screenSize(3)/4 - 2*horOffset, 2*screenSize(4)/3 - 2*vertOffset];

buttonPosition1 = [horOffset/2, vertOffset, normalizedPosition1(3)/4, normalizedPosition1(4)/11];
buttonPosition2 = [normalizedPosition1(3)/4, vertOffset, normalizedPosition1(3)/2, normalizedPosition1(4)/11];
buttonPosition3 = [3*normalizedPosition1(3)/4, 5*vertOffset/3, normalizedPosition1(3)/4, normalizedPosition1(4)/22];

textPosition1 = [horOffset/2, 11*vertOffset/10, normalizedPosition1(3), normalizedPosition1(4)/27];

scale = 16;

% Display Variables
fig = figure('Position', normalizedPosition1, 'Toolbar', 'none', 'Menubar', 'none');
set(fig, 'Resize', 'off');
set(fig,'NumberTitle', 'off');
title('User Inputs', 'FontName', 'Calibri', 'FontSize', 16);
text(0, (scale-1)/scale, sprintf('Cruise Altitude: %.0f ft', cruisealt), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
text(0, (scale-2)/scale, sprintf('Takeoff Altitude: %.0f ft', takeoffalt), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
text(0, (scale-3)/scale, sprintf('Cruise Velocity: %.2f lbs', cruisev), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
text(0, (scale-4)/scale, sprintf('Runway Length: %.0f ft', runway_length), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
text(0, (scale-5)/scale, sprintf('Climb Rate: %.2f ft/s', dh_dt), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
text(0, (scale-6)/scale, sprintf('Propellor Efficiency: %.2f', eta), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
text(0, (scale-7)/scale, sprintf('Payload Weight: %.0f lbs', W_pl), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
text(0, (scale-8)/scale, sprintf('Range: %.0f ft', Range), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
text(0, (scale-9)/scale, sprintf('Average Tailwind: %.0f kts', wind), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
text(0, (scale-10)/scale, sprintf('Lift to Drag Ratio: %.0f', LD), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
text(0, (scale-11)/scale, sprintf('Specific Fuel Consumption: %.2f', SFC), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
text(0, (scale-12)/scale, sprintf('Empty Weight Fraction: %.2f', EWF), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
text(0, (scale-13)/scale, sprintf('Max Lift Coefficient: %.2f', Clmax), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
text(0, (scale-14)/scale, sprintf('Parasitic Drag Coefficient: %.2f', CD0), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
axis off;

labelText = uicontrol('Style', 'text', 'String', 'Edit Input:', 'Position', buttonPosition1, ...
    'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
variableNames = {'Cruise Altitude', 'Takeoff Weight', 'Cruise Velocity', 'Runway Length', ...
    'Climb Rate', 'Propellor Efficiency', 'Payload Weight', 'Range', 'Average Tailwind', 'Lift to Drag Ratio', ...
    'Specific Fuel Consumption', 'Empty Weight Fraction', 'Max Lift Coefficient', 'Parasitic Drag Coefficient'};
variableMenu = uicontrol(fig, 'Style', 'popupmenu', 'String', variableNames, 'Position', buttonPosition2, ...
    'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
txtBox = uicontrol('Style', 'edit', 'Position', buttonPosition3, 'FontName', 'Calibri', 'FontSize', 14);
UpdateButton = uicontrol('Style', 'pushbutton', 'String', 'Update Inputs', ...
'Position', [0,0,normalizedPosition1(3)/2,normalizedPosition1(4)/scale], 'Callback', @updateVariables, ...
'FontName', 'Calibri', 'FontSize', 16); 
OkButton = uicontrol('Style', 'pushbutton', 'String', 'Ok', ...
'Position', [normalizedPosition1(3)/2,0,normalizedPosition1(3)/2,normalizedPosition1(4)/scale], 'Callback', @mainMenu, ...
'FontName', 'Calibri', 'FontSize', 16); 


    % Callback function for update button
    function updateVariables(~, ~)
        % Get selected variable name from dropdown menu
        selectedVariableIndex = get(variableMenu, 'Value');
        selectedVariableName = variableNames{selectedVariableIndex};

        % Get the new value from the edit text box
        newValue = str2double(txtBox.String);

        % Update the selected variable
        if ~isnan(newValue)
            switch selectedVariableName
                case 'Cruise Altitude'
                    cruisealt = newValue;
                case 'Takeoff Weight'
                    takeoffalt = newValue;
                case 'Cruise Velocity'
                    cruisev = newValue;
                case 'Runway Length'
                    runway_length = newValue;
                case 'Climb Rate'
                    dh_dt = newValue;
                case 'Propellor Efficiency'
                    eta = newValue;
                case 'Payload Weight'
                    W_pl = newValue;
                case 'Range'
                    Range = newValue;
                case 'Averagen Tailwind'
                    wind = newValue;    
                case 'Lift to Drag Ratio'
                    LD = newValue;
                case 'Specific Fuel Consumption'
                    SFC = newValue;
                case 'Empty Weight Fraction'
                    EWF = newValue;
                case 'Max Lift Coefficient'
                    Clmax = newValue;
                case 'Parasitic Drag Coefficient'
                    CD0 = newValue;
                clc;
                otherwise
                    labelText = uicontrol('Style', 'text', 'String', 'Invalid Input', ...
                    'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
                    return;
            end
        else
            labelText = uicontrol('Style', 'text', 'String', 'Invalid Input', ...
                'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
        end

        close all;
        
        % Display Results
        inputVariables = [cruisealt,takeoffalt,cruisev,runway_length,dh_dt,eta,W_pl,Range,wind,LD,SFC,EWF,Clmax,CD0];
        inputFigure(inputVariables,horsepower)
        clc;
        labelText = uicontrol('Style', 'text', 'String', 'Values Have Been Updated!', ...
            'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    end

function mainMenu(~,~)
    close all; % Close all open figures
    SizingToolInputs(1,horsepower,inputVariables);
end

end