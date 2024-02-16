function displayResults1(EWF,W_pl,Range,eta,Clmax,CD0, ...
    W_toval,W_eval,W_fval,W_S,W_P,P_W,horsepower,minhp,inputVariables,segmentVariables,constraintscale,totT,carpetPlotVars,carpetscale)
% Function to Display Results
    segmts = inputVariables(1);
    Range = inputVariables(2);
    takeoffalt = inputVariables(3);
    runway_length = inputVariables(4);
    dh_dt = inputVariables(5);
    eta = inputVariables(6);
    W_pl = inputVariables(7);
    EWF = inputVariables(8);
    CD0 = inputVariables(9);
    Clmax = inputVariables(10);
    wRF = inputVariables(11);
    WS = inputVariables(12);
    AR = inputVariables(13);
    osw = inputVariables(14);
    constraintscale = inputVariables(15);

    bregTypes = segmentVariables(:,1);
    dists = segmentVariables(:,2);
    velocs = segmentVariables(:,3);
    vWind = segmentVariables(:,4);
    alt = segmentVariables(:,5);
    SFCs = segmentVariables(:,6);

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
    errorFigurePosition = [0,screenSize(4)/2,screenSize(3)/4,screenSize(4)/7];

    textPosition1 = [horOffset,vertOffset/5,normalizedPosition2(3),normalizedPosition2(4)/12];
    
    % Calculate Variables
    W_area = W_toval/W_S; % Wing Area, in ft^2
    
    if horsepower == 0
        horsepower = P_W * W_toval; % Horsepower, in lbs
    else
        W_P = W_toval/horsepower;
        P_W = horsepower/W_toval;
    end
    
    timeDays = floor(totT/24);
    timeHoursMinusDays = round(totT - timeDays * 24);
    
    % Store Segment Variables
    i = 1;
    for i = 1:segmts
        segmentNumber(i) = i;
    end

    % Store Variable Titles
    wind = inputVariables(9);
    inputVariableNames = {'Segments', 'Range', 'Takeoff Altitude', 'Runway Length', ...
        'Climb Rate', 'Propellor Efficiency', 'Payload Weight', 'Empty Weight Fraction', 'Parasitic Drag Coefficient','Constraint Diagram Scale','Reserve Fuel', ...
        'Wing Loading', 'Aspect Ratio', 'Oswald Efficiency', 'Constraint Diagram Scale'};
    segmentVariableNames = {'Segment Number','Bruguet Range Type','Distances (ft)','True Aispeed (kts)',...
        'Avg Tailwind (kts)','Altitude (ft)','SFC'};
    CalculatedVariableNames = {'Total Weight (lbs)','Empty Weight (lbs)','Fuel Weight(lbs)',...
        'W_S (lbs/ft^2)','Wing Area (ft^2)','P_W (hp/lbs)','W_P (lbs/hp','Horsepower','Time (hours)'};
    Titles = inputVariableNames;

    for i = 1:segmts
        Titles = [Titles,segmentVariableNames];
    end
    Titles = [Titles, CalculatedVariableNames];


    % Store Variables
    CalculatedVariables = [W_toval,W_eval,W_fval,W_S,W_area,P_W,W_P,horsepower,totT];
    Values = inputVariables;
    for i = 1:segmts
        Values = [Values,segmentNumber(i),bregTypes(i),dists(i),velocs(i),vWind(i),alt(i),SFCs(i)];
    end
    
    Values = [Values,CalculatedVariables];
    ValuesCell = num2cell(Values(:));
    
    %% Given Variables Figure
    
    scale = 10;
    fig6 = figure('Position', normalizedPosition1, 'Toolbar', 'none', 'Menubar', 'none');
    set(fig6, 'Resize', 'off');
    set(fig6,'NumberTitle', 'off');
    title('Given Variables', 'FontName', 'Calibri', 'FontSize', 16);
    
    % Display individual variables
    text(0, (scale-1)/scale, sprintf('Empty Weight Fraction: %.2f', EWF), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-2)/scale, sprintf('Payload Weight: %.0f lbs', W_pl), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-3)/scale, sprintf('Range: %.0f nautical miles', Range), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-4)/scale, sprintf('Propeller Efficiency: %.2f', eta), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-5)/scale, sprintf('Max Lift Coefficient: %.2f', Clmax), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-6)/scale, sprintf('Parasitic Drag Coefficent: %.2f', CD0), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-7)/scale, sprintf('Aspect Ratio: %.2f', AR), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-8)/scale, sprintf('Reserve Fuel: %.2f lbs', wRF), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    axis off;
    clearbtn = uicontrol('Style', 'pushbutton', 'String', 'Clear All Figures', ...
        'Position', buttonPosition1, 'Callback', @clearAllFigures, ...
        'FontName', 'Calibri', 'FontSize', 14); 
    uploadbtn = uicontrol('Style', 'pushbutton', 'String', 'Save Data', ...
        'Position', buttonPosition2, 'Callback', @saveData, ...
        'FontName', 'Calibri', 'FontSize', 14); 
    backbtn = uicontrol('Style', 'pushbutton', 'String', 'Edit Inputs', ...
        'Position', backButtonPosition, 'Callback', @editInputs, ...
        'FontName', 'Calibri', 'FontSize', 14); 
    runbtn = uicontrol('Style', 'pushbutton', 'String', 'Run Tests', ...
        'Position', runFunctionPosition, 'Callback', @runTests, ...
        'FontName', 'Calibri', 'FontSize', 14);
    
    %% Calculated Variables Figure
    
    scale = 12;
    fig7 = figure('Position', normalizedPosition2, 'Toolbar', 'none', 'Menubar', 'none');
    set(fig7, 'Resize', 'off');
    set(fig7,'NumberTitle', 'off');
    title('Calculated Variables', 'FontName', 'Calibri', 'FontSize', 16);
    text(0, (scale-1)/scale, sprintf('Total Weight: %.0f lbs', W_toval), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-2)/scale, sprintf('Empty Weight: %.0f lbs', W_eval), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-3)/scale, sprintf('Fuel Weight: %.0f lbs', W_fval), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-4)/scale, sprintf('Wing Loading: %.2f lbs/ft^2', W_S), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-5)/scale, sprintf('Wing Area: %.2f ft^2', W_area), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-6)/scale, sprintf('Power to Weight: %.3f hp/lbs', P_W), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-7)/scale, sprintf('Power Loading: %.2f lbs/hp', W_P), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-8)/scale, sprintf('Horsepower: %.2f hp', horsepower), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-9)/scale, sprintf('Time to complete route: '), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-10)/scale, sprintf('  %.0f days and %.0f hours', timeDays,timeHoursMinusDays), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    axis off;
    
    labelText = uicontrol('Style', 'text', 'String', 'Enter Wing Loading:', 'Position', buttonPosition3, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    txtBox = uicontrol('Style', 'edit', 'Position', buttonPosition4, 'FontName', 'Calibri', 'FontSize', 14);
    saveButton = uicontrol('Style', 'pushbutton', 'String', 'Update', 'Position', buttonPosition5, 'Callback', @saveNumber, 'FontName', 'Calibri', 'FontSize', 14); 
    
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

            % Store Given Mission Data
            runDataInput = data(row,:);
            
            segmts = runDataInput(1);
            Range = runDataInput(2);
            takeoffalt = runDataInput(3);
            runway_length = runDataInput(4);
            dh_dt = runDataInput(5);
            eta = runDataInput(6);
            W_pl = runDataInput(7);
            EWF = runDataInput(8);
            CD0 = runDataInput(9);
            Clmax = runDataInput(10);
            wRF = runDataInput(11);
            WS = runDataInput(12);
            AR = runDataInput(13);
            osw = runDataInput(14);
            constraintscale = runDataInput(15);
    
            segmts = cell2mat(segmts);
            Range = cell2mat(Range);
            takeoffalt = cell2mat(takeoffalt);
            runway_length = cell2mat(runway_length);
            dh_dt = cell2mat(dh_dt);
            eta = cell2mat(eta);
            W_pl = cell2mat(W_pl);
            EWF = cell2mat(EWF);
            CD0 = cell2mat(CD0);
            Clmax = cell2mat(Clmax);
            wRF = cell2mat(wRF);
            WS = cell2mat(WS);
            AR = cell2mat(AR);
            osw = cell2mat(osw);
            constraintscale = cell2mat(constraintscale);
            horsepower = 0;
            
            % Store Segment Data
            for i = 1:segmts
                segmentNumber1 = runDataInput(15+(7*(i-1))+1);
                bregTypes1 = runDataInput(15+(7*(i-1))+2);
                dists1 = runDataInput(15+(7*(i-1))+3);
                velocs1 = runDataInput(15+(7*(i-1))+4);
                vWind1 = runDataInput(15+(7*(i-1))+5);
                alt1 = runDataInput(15+(7*(i-1))+6);
                SFCs1 = runDataInput(15+(7*(i-1))+7);

                segmentNumber1 = cell2mat(segmentNumber1);
                bregTypes1 = cell2mat(bregTypes1);
                dists1 = cell2mat(dists1);
                velocs1 = cell2mat(velocs1);
                vWind1 = cell2mat(vWind1);
                alt1 = cell2mat(alt1);
                SFCs1 = cell2mat(SFCs1);

                segmentNumber(i) = segmentNumber1;
                bregTypes(i) = bregTypes1;
                dists(i) = dists1;
                velocs(i) = velocs1;
                vWind(i) = vWind1;
                alt(i) = alt1;
                SFCs(i) = SFCs1;
            end

            % Calculate Weight Data

            % Fix Range if Broken
            if sum(dists) ~= Range
                dists = Range / segmts + zeros(segmts,1);
                segmentVariables(:,2) = dists;
            end
    
            [Result] = weightFromSegments(bregTypes,dists,velocs,vWind,alt,SFCs,W_pl,wRF,WS,EWF,eta,AR,osw,CD0);
            W_fval = (Result(1) - (Result(1) * EWF + W_pl + wRF));
            W_eval = Result(1)-W_fval-W_pl;
    
            % Display Results
            MTOW = Result(1);
            W_toval = MTOW;
            fFuel = Result(2:end,1);
            
            % "Hand Calc" to check if calculated fuel fraction acheives the desired range
            [range,x,totT,t,avgV] = rangeFromFuelFractions(bregTypes,MTOW,fFuel,dists,velocs,vWind,alt,SFCs,WS,EWF,eta,AR,osw,CD0);
            
            % Plot Segment Results
            [xMission,wMission,rhoMission,CLMission,LDMission] = ...
                missionProfileSegments(10,[0,1],bregTypes,MTOW,fFuel,...
                dists,velocs,vWind,alt,SFCs,WS,EWF,eta,AR,osw,CD0);

            % Calculate Constraint Data
            cruisev = max(velocs);
            LD = max(LDMission);
            cruisealt = min(alt);
            [W_Sval,W_Pval,P_Wval,minhp] = constraintDiagramFunction1(0,constraintscale,cruisealt, ...
                takeoffalt,cruisev,runway_length,dh_dt,LD,Clmax,CD0,eta,horsepower,MTOW,inputVariables);
    
            % Store and Print Outputs
            Warea = W_toval/W_Sval;
            runFullData(:,j) = [runDataInput,W_toval,W_eval,W_fval,W_Sval,W_area,P_Wval,W_Pval,minhp,totT];
        end
        
        % Store Variable Titles
        wind = inputVariables(9);
        inputVariableNames = {'Segments', 'Range', 'Takeoff Altitude', 'Runway Length', ...
            'Climb Rate', 'Propellor Efficiency', 'Payload Weight', 'Empty Weight Fraction', 'Parasitic Drag Coefficient','Constraint Diagram Scale','Reserve Fuel', ...
            'Wing Loading', 'Aspect Ratio', 'Oswald Efficiency', 'Constraint Diagram Scale'};
        segmentVariableNames = {'Segment Number','Bruguet Range Type','Distances (ft)','True Airspeed (kts)',...
            'Avg Tailwind (kts)','Altitude (ft)','SFC'};
        CalculatedVariableNames = {'Total Weight (lbs)','Empty Weight (lbs)','Fuel Weight(lbs)',...
            'W_S (lbs/ft^2)','Wing Area (ft^2)','P_W (hp/lbs)','W_P (lbs/hp','Horsepower','Time (hours)'};
        Titles = inputVariableNames;
    
        for i = 1:segmts
            Titles = [Titles,segmentVariableNames];
        end
        Titles = [Titles, CalculatedVariableNames];

        % Store Variables
        CalculatedVariables = [W_toval,W_eval,W_fval,W_S,W_area,P_W,W_P,horsepower,totT];
        Values = inputVariables;
        for i = 1:segmts
            Values = [Values,segmentNumber(i),bregTypes(i),dists(i),velocs(i),alt(i),SFCs(i)];
        end
        
        Values = [Values,CalculatedVariables];
        ValuesCell = num2cell(Values(:));
            
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
        breguetSegmentTester(1,horsepower,inputVariables,segmentVariables,carpetPlotVars,carpetscale);
    end
    
    function editInputs(~,~)
        close all; % Back to Input Menu
        inputFigure1(inputVariables,segmentVariables,horsepower,constraintscale,carpetPlotVars,carpetscale);
    end
    
    function saveNumber(~, ~)
        % Get the value from the textbox
        number = str2double(get(txtBox, 'String'));
        W_Sold = inputVariables(12);
        % Check if the input is a valid number
        if ~isnan(number)
            % Store the number as a variable (you can change 'savedNumber' to any variable name)
            try
                close all;
                W_S = number;
                inputVariables(12) = W_S;
                breguetSegmentTester(1,horsepower,inputVariables,segmentVariables,carpetPlotVars,carpetscale);
                if inputVariables(12) == W_Sold
                    labelText = uicontrol('Style', 'text', 'String', 'The input wing loading was invalid.', ...
                        'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
                else
                    labelText = uicontrol('Style', 'text', 'String', 'Figures Have Been Updated!', ...
                        'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
                end
            catch ME
                % If an error occurs, display an error message
                inputVariables(12) = W_Sold;
            end
                breguetSegmentTester(1,horsepower,inputVariables,segmentVariables,carpetPlotVars,carpetscale);
                if inputVariables(12) == W_Sold
                    labelText = uicontrol('Style', 'text', 'String', 'The input wing loading was invalid.', ...
                        'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
                else
                    labelText = uicontrol('Style', 'text', 'String', 'Figures Have Been Updated!', ...
                        'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
                end
        else
            labelText = uicontrol('Style', 'text', 'String', 'Invalid Input', ...
                'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
        end
    end


%     function saveNumber(~, ~)
%         % Get the value from the textbox
%         number = str2double(get(txtBox, 'String'));
%         % Check if the input is a valid number
%         if ~isnan(number)
%             if number <= minhp
%                 labelText = uicontrol('Style', 'text', 'String', 'This horsepower is too low.', ...
%                     'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
%                 return
%             end
%             % Store the number as a variable (you can change 'savedNumber' to any variable name)
%             horsepower = number; 
%             close all;
%             breguetSegmentTester(1,horsepower,inputVariables,segmentVariables,carpetPlotVars,carpetscale)
%             labelText = uicontrol('Style', 'text', 'String', 'Figures Have Been Updated!', ...
%                 'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
%         else
%             labelText = uicontrol('Style', 'text', 'String', 'Invalid Input', ...
%                 'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
%         end
%     end

end
