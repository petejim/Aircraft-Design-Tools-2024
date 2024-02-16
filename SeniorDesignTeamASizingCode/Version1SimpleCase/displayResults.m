function displayResults(LD,SFC,EWF,W_pl,cruisealt,cruisev,Range,eta,Clmax,CD0, ...
    W_toval,W_eval,W_fval,W_S,W_P,P_W,horsepower,constraintinputs,minhp,inputVariables)
% Function to Display Results

% Display Position Variables
screenSize = get(0, 'ScreenSize');
horOffset = screenSize(3)/100;
vertOffset = screenSize(4)/25;
normalizedPosition1 = [horOffset, vertOffset, screenSize(3)/4 - 2*horOffset, 5*screenSize(4)/11 - 2*vertOffset];
normalizedPosition2 = [screenSize(3)/4+horOffset, vertOffset, screenSize(3)/4 - 2*horOffset, 5*screenSize(4)/11 - 2*vertOffset];

buttonPosition1 = [0, normalizedPosition1(4)/11, normalizedPosition1(3)/2-horOffset/10, normalizedPosition1(4)/11];
buttonPosition2 = [normalizedPosition1(3)/2, normalizedPosition1(4)/11, normalizedPosition1(3)/2-horOffset/10, normalizedPosition1(4)/11];
backButtonPosition = [0, 0, normalizedPosition1(3)/2-horOffset/10, normalizedPosition1(4)/11];
runFunctionPosition = [normalizedPosition1(3)/2, 0, normalizedPosition1(3)/2-horOffset/10, normalizedPosition1(4)/11];

buttonPosition3 = [horOffset/2, vertOffset, normalizedPosition2(3)/2, normalizedPosition2(4)/11];
buttonPosition4 = [normalizedPosition2(3)/2+horOffset/2, 5*vertOffset/4, normalizedPosition1(3)/5, normalizedPosition1(4)/16];
buttonPosition5 = [3*normalizedPosition2(3)/4, 5*vertOffset/4, normalizedPosition1(3)/4, normalizedPosition1(4)/15];

saveFigurePosition1 = [horOffset,screenSize(4)/2,screenSize(3)/4,screenSize(4)/7];
% saveFigurePosition2 = [horOffset,screenSize(4)/2,screenSize(3)/4,screenSize(4)/7];

textPosition1 = [horOffset,vertOffset/5,normalizedPosition2(3),normalizedPosition2(4)/12];

% Calculate Variables
W_structure = W_fval-W_pl; % Structural Weight, in lbs
W_area = W_toval/W_S; % Wing Area, in ft^2

if horsepower == 0
    horsepower = P_W * W_toval; % Horsepower, in lbs
else
    W_P = W_toval/horsepower;
    P_W = horsepower/W_toval;
end

% Store Variables
wind = inputVariables(9);
inputVariableNames = {'Cruise Alt (ft)','Takeoff Alt (ft)','Cruise Velo (kts)','Runway Length (ft)','Climb Rate (ft/s)',...
    'Prop Efficiency','Payload Weight (lbs)','Range (ft)','Avg Tailwind (kts)','L/D','SFC','EWF','CL max','CD0'};
CalculatedVariableNames = {'Total Weight (lbs)','Empty Weight (lbs)','Fuel Weight(lbs)',...
    'Structural Weight (lbs)','W_S (lbs/ft^2)','Wing Area (ft^2)','P_W (hp/lbs)','W_P (lbs/hp','Horsepower'};
Titles = [inputVariableNames, CalculatedVariableNames];
CalculatedVariables = [W_toval,W_eval,W_fval,W_structure,W_S,W_area,P_W,W_P,horsepower];
Values = [inputVariables,CalculatedVariables];
ValuesCell = num2cell(Values(:));

%% Given Variables Figure

scale = 13;
fig6 = figure('Position', normalizedPosition1, 'Toolbar', 'none', 'Menubar', 'none');
set(fig6, 'Resize', 'off');
set(fig6,'NumberTitle', 'off');
title('Given Variables', 'FontName', 'Calibri', 'FontSize', 16);

% Display individual variables
text(0, (scale-1)/scale, sprintf('Lift to Drag Ratio: %.2f', LD), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-2)/scale, sprintf('Specific Fuel Consumption: %.2f', SFC), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-3)/scale, sprintf('Empty Weight Fraction: %.2f', EWF), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-4)/scale, sprintf('Payload Weight: %.0f lbs', W_pl), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-5)/scale, sprintf('Cruise Altitude: %.0f ft', cruisealt), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-6)/scale, sprintf('Cruise Velocity: %.0f knots', cruisev), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-7)/scale, sprintf('Range: %.0f nautical miles', Range), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-8)/scale, sprintf('Average Tailwind: %.0f kts', wind), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-9)/scale, sprintf('Propeller Efficiency: %.2f', eta), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-10)/scale, sprintf('Max Lift Coefficient: %.2f', Clmax), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-11)/scale, sprintf('Parasitic Drag Coefficent: %.2f', CD0), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
axis off;
clearbtn = uicontrol('Style', 'pushbutton', 'String', 'Clear All Figures', ...
    'Position', buttonPosition1, 'Callback', @clearAllFigures, ...
    'FontName', 'Calibri', 'FontSize', 12); 
uploadbtn = uicontrol('Style', 'pushbutton', 'String', 'Save Data', ...
    'Position', buttonPosition2, 'Callback', @saveData, ...
    'FontName', 'Calibri', 'FontSize', 12); 
backbtn = uicontrol('Style', 'pushbutton', 'String', 'Edit Inputs', ...
    'Position', backButtonPosition, 'Callback', @editInputs, ...
    'FontName', 'Calibri', 'FontSize', 12); 
runbtn = uicontrol('Style', 'pushbutton', 'String', 'Run Tests', ...
    'Position', runFunctionPosition, 'Callback', @runTests, ...
    'FontName', 'Calibri', 'FontSize', 12);

%% Calculated Variables Figure

scale = 12;
fig7 = figure('Position', normalizedPosition2, 'Toolbar', 'none', 'Menubar', 'none');
set(fig7, 'Resize', 'off');
set(fig7,'NumberTitle', 'off');
title('Calculated Variables', 'FontName', 'Calibri', 'FontSize', 16);
text(0, (scale-1)/scale, sprintf('Total Weight: %.0f lbs', W_toval), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-2)/scale, sprintf('Empty Weight: %.0f lbs', W_eval), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-3)/scale, sprintf('Fuel Weight: %.0f lbs', W_fval), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-4)/scale, sprintf('Structural Weight: %.0f lbs', W_structure), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-5)/scale, sprintf('Wing Loading: %.2f lbs/ft^2', W_S), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-6)/scale, sprintf('Wing Area: %.2f ft^2', W_area), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-7)/scale, sprintf('Power to Weight: %.3f hp/lbs', P_W), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-8)/scale, sprintf('Power Loading: %.2f lbs/hp', W_P), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
text(0, (scale-9)/scale, sprintf('Horsepower: %.2f hp', horsepower), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
axis off;

labelText = uicontrol('Style', 'text', 'String', 'Enter New Horsepower:', 'Position', buttonPosition3, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 12);
txtBox = uicontrol('Style', 'edit', 'Position', buttonPosition4, 'FontName', 'Calibri', 'FontSize', 12);
saveButton = uicontrol('Style', 'pushbutton', 'String', 'Update', 'Position', buttonPosition5, 'Callback', @saveNumber, 'FontName', 'Calibri', 'FontSize', 12); 

%% Additional Functions

% Callback function to clear all figures
function clearAllFigures(~, ~)
    close all; % Close all open figures
end

%% Run Tests

% Runs Iterations
function runTests(~,~)
    close all;
    fig = figure('Position', saveFigurePosition1, 'Toolbar', 'none', 'Menubar', 'none');
    set(fig, 'Resize', 'off');
    set(fig,'NumberTitle', 'off');
    uicontrol('Style', 'text', 'String', 'Select File to Open', 'Position', ...
        [0, 3*saveFigurePosition1(4)/5, saveFigurePosition1(3), saveFigurePosition1(4)/6], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 16);
    uicontrol('Style', 'text', 'String', 'Please ensure the file is formatted correctly.', 'Position', ...
        [0, 2*saveFigurePosition1(4)/5, saveFigurePosition1(3), saveFigurePosition1(4)/6], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    cancelButton = uicontrol('Style', 'pushbutton', 'String', 'Cancel', ...
        'Position', [3*saveFigurePosition1(3)/4,3*saveFigurePosition1(4)/4,saveFigurePosition1(3)/4,saveFigurePosition1(4)/4], ...
        'Callback', @mainMenu, 'FontName', 'Calibri', 'FontSize', 12); 

    % Choose File to Read
    [fileName, filePath, filterIndex] = uigetfile('*.mat', 'Select a .mat File');

    % Check if the user selected a file
    if isequal(fileName, 0)
        labelText = uicontrol('Style', 'text', 'String', 'No file selected.', 'Position', ...
            [horOffset/4, 5, saveFigurePosition1(3), saveFigurePosition1(4)/9], ...
            'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 12);
        return;
    end

    % Combine file name and path to get the full file path
    selectedFile = fullfile(filePath, fileName);

    % Load the variables from the MAT file
    loadedData = load(selectedFile);

    % Access the numeric data from the loaded variables
    data = loadedData.data;  % Assuming the variable name is 'data'
    
    % Number of rows and columns in the numeric data
    numRows = size(data, 1);
    
    % Loop through rows and save to individual variables
    i = 1;
    for row = 2:numRows
        j = row-1;
        % Store Given Data
        runDataInput = data(row,:);
        cruisealt = runDataInput(1);
        takeoffalt = runDataInput(2);
        cruisev = runDataInput(3);
        runway_length = runDataInput(4);
        dh_dt = runDataInput(5);
        eta = runDataInput(6);
        W_pl = runDataInput(7);
        R = runDataInput(8);
        wind = runDataInput(9);
        LD = runDataInput(10);
        SFC = runDataInput(11);
        EWF = runDataInput(12);
        Clmax = runDataInput(13);
        CD0 = runDataInput(14);

        cruisealt = cell2mat(cruisealt);
        takeoffalt = cell2mat(takeoffalt);
        cruisev = cell2mat(cruisev);
        runway_length = cell2mat(runway_length);
        dh_dt = cell2mat(dh_dt);
        eta = cell2mat(eta);
        W_pl = cell2mat(W_pl);
        R = cell2mat(R);
        wind = cell2mat(wind);
        LD = cell2mat(LD);
        SFC = cell2mat(SFC);
        EWF = cell2mat(EWF);
        Clmax = cell2mat(Clmax);
        CD0 = cell2mat(CD0);
        horsepower = 0;
        
        % Calculate Data
        [W_toval, W_eval, W_fval] = carpetPlotFunction(0,0,LD,SFC,EWF,eta,0,0,0,0,0,0, ...
            W_pl,R,wind,cruisev,0,horsepower,inputVariables);
        [W_Sval,W_Pval,P_Wval,minhp] = constraintDiagramFunction(0,0,cruisealt,takeoffalt,cruisev,...
            runway_length,dh_dt,LD,Clmax,CD0,eta,horsepower,W_toval);

        % Store and Print Outputs
        W_structure = W_eval-W_pl;
        Warea = W_toval/W_S;
        runFullData(:,j) = [runDataInput,W_toval, W_eval, W_fval,W_structure,W_Sval,W_S,W_Pval,P_Wval,minhp];
    end
    
    inputVariableNames = {'Cruise Alt (ft)','Takeoff Alt (ft)','Cruise Velo (kts)','Runway Length (ft)','Climb Rate (ft/s)',...
        'Prop Efficiency','Payload Weight (lbs)','Range (ft)','Avg Tailwind (kts)','L/D','SFC','EWF','CL max','CD0'};
    CalculatedVariableNames = {'Total Weight (lbs)','Empty Weight (lbs)','Fuel Weight(lbs)',...
        'Structural Weight (lbs)','W_S (lbs/ft^2)','Wing Area (ft^2)','W_P (lbs/hp','P_W (hp/lbs)','Horsepower'};
    Titles = [inputVariableNames, CalculatedVariableNames];
    data = [Titles; runFullData'];
    save(fullfile(selectedFile), 'data');

    % Display that the data was saved
    close all; 
    fig = figure('Position', saveFigurePosition1, 'Toolbar', 'none', 'Menubar', 'none');
    set(fig, 'Resize', 'off');
    set(fig,'NumberTitle', 'off');
    uicontrol('Style', 'text', 'String', 'The data in your file has been updated!', 'Position', ...
    [0, 2*saveFigurePosition1(4)/5, saveFigurePosition1(3), saveFigurePosition1(4)/4], ...
    'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 16);
    newSaveButton = uicontrol('Style', 'pushbutton', 'String', 'OK', ...
    'Position', [0,0,saveFigurePosition1(3)/2,saveFigurePosition1(4)/4], 'Callback', @mainMenu, ...
    'FontName', 'Calibri', 'FontSize', 16); 
end

%% Save Data
function saveData(~,~)
    close all; 

    % Save Data Figure
    fig = figure('Position', saveFigurePosition1, 'Toolbar', 'none', 'Menubar', 'none');
    set(fig, 'Resize', 'off');
    set(fig,'NumberTitle', 'off');
    uicontrol('Style', 'text', 'String', 'Would you like to create a new save?', 'Position', ...
        [0, 3*saveFigurePosition1(4)/5, saveFigurePosition1(3), saveFigurePosition1(4)/6], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 16);
    newSaveButton = uicontrol('Style', 'pushbutton', 'String', 'Yes', ...
    'Position', [0,saveFigurePosition1(4)/5,saveFigurePosition1(3)/2,saveFigurePosition1(4)/4], 'Callback', @newSave, ...
    'FontName', 'Calibri', 'FontSize', 16); 
    overwriteButton = uicontrol('Style', 'pushbutton', 'String', 'No', ...
    'Position', [saveFigurePosition1(3)/2,saveFigurePosition1(4)/5,saveFigurePosition1(3)/2,saveFigurePosition1(4)/4], 'Callback', @overwriteData, ...
    'FontName', 'Calibri', 'FontSize', 16); 
    cancelButton = uicontrol('Style', 'pushbutton', 'String', 'Cancel', ...
    'Position', [3*saveFigurePosition1(3)/4,3*saveFigurePosition1(4)/4,saveFigurePosition1(3)/4,saveFigurePosition1(4)/4], 'Callback', @mainMenu, ...
    'FontName', 'Calibri', 'FontSize', 12); 

%% Overwrite Data    
    % Select Data File to Overwrite
    function overwriteData(~, ~)
        % Get the path of the currently executing script
        scriptPath = fileparts(mfilename('fullpath'));
        
        % Specify the "SavedData" folder path
        savedDataFolder = fullfile(scriptPath, 'SavedData');
        
        % Check if the "SavedData" folder exists
        if ~exist(savedDataFolder, 'dir')
            % Create the "SavedData" folder if it doesn't exist
            mkdir(savedDataFolder);
        end

        % Check if there are any files in the "SavedData" folder
        files = dir(fullfile(savedDataFolder, '*.mat'));
        if isempty(files)
            labelText = uicontrol('Style', 'text', 'String', 'No existing data files found, create new file!', 'Position', ...
                    [horOffset/4,5,saveFigurePosition1(3),saveFigurePosition1(4)/9], ...
                    'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 12);
            return;
        end

        % Allow the user to select an existing data file
        [fileName, filePath] = uigetfile(fullfile(savedDataFolder, '*.mat'), 'Select an existing data file');

        % Check if the user canceled the selection
        if fileName == 0
            disp('File selection canceled.');
            return;
        end
        
       % Load the existing data file
        fullFilePath = fullfile(filePath, fileName);
        loadedData = load(fullFilePath);
        
        % Access the loaded variables dynamically
        variableNames = fieldnames(loadedData);
        for i = 1:length(variableNames)
            variableData = loadedData.(variableNames{i});
        end
        existingData = variableData;

        % Get the new data to be added (replace this with your new data)
        % For example, you can use uicontrols to get input from the user
        newDataRow = ValuesCell; % Replace with your new data values

        % Add new data below existing data
        updatedData = [existingData; newDataRow'];
        
        % Save the updated data back to the same file
        save(fullFilePath, 'updatedData');

        % Display that the data has been saved
        close all; 
        fig = figure('Position', saveFigurePosition1, 'Toolbar', 'none', 'Menubar', 'none');
        set(fig, 'Resize', 'off');
        set(fig,'NumberTitle', 'off');
        uicontrol('Style', 'text', 'String', 'Your data was saved!', 'Position', ...
        [0, 2*saveFigurePosition1(4)/5, saveFigurePosition1(3), saveFigurePosition1(4)/4], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 16);
        newSaveButton = uicontrol('Style', 'pushbutton', 'String', 'OK', ...
        'Position', [0,0,saveFigurePosition1(3)/2,saveFigurePosition1(4)/4], 'Callback', @mainMenu, ...
        'FontName', 'Calibri', 'FontSize', 16); 
    end

%% Save New Data
    % Name New Save
    function newSave(~,~)
        close all; 
        fig = figure('Position', saveFigurePosition1, 'Toolbar', 'none', 'Menubar', 'none');
        set(fig, 'Resize', 'off');
        set(fig,'NumberTitle', 'off');
        uicontrol('Style', 'text', 'String', 'What would you like to name your new save?', 'Position', ...
            [0, 2*saveFigurePosition1(4)/5, saveFigurePosition1(3), saveFigurePosition1(4)/4], ...
            'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 16);
        nameBox = uicontrol('Style', 'edit', 'Position', [0,saveFigurePosition1(4)/7,3*saveFigurePosition1(3)/4,saveFigurePosition1(4)/4], ...
            'FontName', 'Calibri', 'FontSize', 12);
        saveNameButton = uicontrol('Style', 'pushbutton', 'String', 'Save', 'Position', ...
            [3*saveFigurePosition1(3)/4,saveFigurePosition1(4)/7,saveFigurePosition1(3)/4,saveFigurePosition1(4)/4], ...
            'Callback', @uploadNewSave, 'FontName', 'Calibri', 'FontSize', 12); 
        cancelButton = uicontrol('Style', 'pushbutton', 'String', 'Cancel', ...
            'Position', [3*saveFigurePosition1(3)/4,3*saveFigurePosition1(4)/4,saveFigurePosition1(3)/4,saveFigurePosition1(4)/4], ...
            'Callback', @mainMenu, 'FontName', 'Calibri', 'FontSize', 12); 
        
        % Create New Save
        function uploadNewSave(~,~)
            fileName = get(nameBox, 'String');
            if isempty(fileName)
                labelText = uicontrol('Style', 'text', 'String', 'Invalid Name: Title cannot be empty.', 'Position', ...
                    [horOffset/4,5,saveFigurePosition1(3)/2,saveFigurePosition1(4)/9], ...
                    'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 12);
                return
            end

            % Get the path of the currently executing script
            scriptPath = fileparts(mfilename('fullpath'));
            
            % Create the "SavedData" folder within the script's path
            savedDataFolder = fullfile(scriptPath, 'SavedData');
            if ~exist(savedDataFolder, 'dir')
                mkdir(savedDataFolder);
            end

            % Use the entered text as the file name
            fileName = [fileName, '.mat'];
            
            % Check if the fileName already exists
            if exist(fullfile(savedDataFolder, fileName), 'file') == 2
                % File already exists, handle accordingly (e.g., display a message)
                labelText = uicontrol('Style', 'text', 'String', 'Invalid Name: File with same name exists.', 'Position', ...
                    [horOffset/4,5,saveFigurePosition1(3)/2,saveFigurePosition1(4)/9], ...
                    'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 12);
                return;
            end

            % Save the variable in the "SavedData" folder
            data = [Titles; ValuesCell'];
            save(fullfile(savedDataFolder, fileName), 'data');

            % Display that the data was saved
            close all; 
            fig = figure('Position', saveFigurePosition1, 'Toolbar', 'none', 'Menubar', 'none');
            set(fig, 'Resize', 'off');
            set(fig,'NumberTitle', 'off');
            uicontrol('Style', 'text', 'String', 'Your data was saved to the Saved Data folder!', 'Position', ...
            [0, 2*saveFigurePosition1(4)/5, saveFigurePosition1(3), saveFigurePosition1(4)/4], ...
            'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 16);
            newSaveButton = uicontrol('Style', 'pushbutton', 'String', 'OK', ...
            'Position', [0,0,saveFigurePosition1(3)/2,saveFigurePosition1(4)/4], 'Callback', @mainMenu, ...
            'FontName', 'Calibri', 'FontSize', 16); 
        end
    end
end

%% Additional Functions

function mainMenu(~,~)
    close all; % Close all open figures
    SizingToolInputs(1,horsepower,inputVariables);
end

function editInputs(~,~)
    close all; % Back to Input Menu
    inputFigure(inputVariables,horsepower);
end

function saveNumber(~, ~)
    % Get the value from the textbox
    number = str2double(get(txtBox, 'String'));
    % Check if the input is a valid number
    if ~isnan(number)
        if number <= minhp
            labelText = uicontrol('Style', 'text', 'String', 'This horsepower is too low.', ...
                'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
            return
        end
        % Store the number as a variable (you can change 'savedNumber' to any variable name)
        horsepower = number; 
        close all;
        SizingToolInputs(1,horsepower,inputVariables)
        labelText = uicontrol('Style', 'text', 'String', 'Figures Have Been Updated!', ...
            'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    else
        labelText = uicontrol('Style', 'text', 'String', 'Invalid Input', ...
            'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    end
end

end
