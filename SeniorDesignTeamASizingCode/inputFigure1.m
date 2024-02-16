function [] ...
        = inputFigure1(inputVariables,segmentVariables,horsepower,constraintscale,carpetPlotVars,carpetscale)
% Input Function Feature

%% Mission Variables
    % Set Variables
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
    
    % Screen Poisition Variables
    screenSize = get(0, 'ScreenSize');
    horOffset = screenSize(3)/100;
    vertOffset = screenSize(4)/25;
    normalizedPosition1 = [horOffset, vertOffset, screenSize(3)/4 - 2*horOffset, 3*screenSize(4)/4 - 2*vertOffset];
    normalizedPosition2 = [screenSize(3)/4, vertOffset, screenSize(3)/4 - 2*horOffset, 3*screenSize(4)/4 - 2*vertOffset];

    buttonPosition1 = [horOffset/2, vertOffset, normalizedPosition1(3)/4, normalizedPosition1(4)/11];
    buttonPosition2 = [normalizedPosition1(3)/4, vertOffset, normalizedPosition1(3)/2, normalizedPosition1(4)/11];
    buttonPosition3 = [3*normalizedPosition1(3)/4, vertOffset+normalizedPosition1(4)/22, normalizedPosition1(3)/4, normalizedPosition1(4)/22];
    
    textPosition1 = [horOffset/2, 11*vertOffset/10, normalizedPosition1(3), normalizedPosition1(4)/27];
    errorFigurePosition = [0,screenSize(4)/2,screenSize(3)/4,screenSize(4)/7];

%% Segmented Mission Variables
    % Normalize if number of segments were increased
    currentSize = numel(bregTypes);
    if currentSize <= segmts
        bregTypes1 = bregTypes;
        bregTypes = zeros(1, segmts);
        bregTypes(:,1:currentSize) = bregTypes1;

        dists1 = dists;
        dists = zeros(1, segmts);
        dists(:,1:currentSize) = dists1;

        velocs1 = velocs;
        velocs = zeros(1, segmts);
        velocs(:,1:currentSize) = velocs1;

        vWind1 = vWind;
        vWind = zeros(1, segmts);
        vWind(:,1:currentSize) = vWind1;

        alt1 = alt;
        alt = zeros(1, segmts);
        alt(:,1:currentSize) = alt1;

        SFCs1 = SFCs;
        SFCs = zeros(1, segmts);
        SFCs(:,1:currentSize) = SFCs1;
    end

    if currentSize > segmts
        bregTypes1 = bregTypes(1:segmts);
        bregTypes = bregTypes1';

        dists1 = dists(1:segmts);
        dists = dists1';

        velocs1 = velocs(1:segmts);
        velocs = velocs1';

        vWind1 = vWind(1:segmts);
        vWind = vWind1';

        alt1 = alt(1:segmts);
        alt = alt1';

        SFCs1 = SFCs(1:segmts);
        SFCs = SFCs1';
    end

    % Produce Figure
    figSeg = figure('Position', normalizedPosition2, 'Toolbar', 'none', 'Menubar', 'none');
    set(figSeg, 'Resize', 'off');
    set(figSeg,'NumberTitle', 'off');
    title('Segment Inputs', 'FontName', 'Calibri', 'FontSize', 16);
    scale = 7*segmts+1;

    for i = 1:segmts
        text(0, (scale-(7*(i-1))-1)/scale, sprintf('Segment %.0f:', i), 'FontName', 'Calibri', 'FontSize', 12, 'HorizontalAlignment', 'left');
        text(0, (scale-(7*(i-1))-2)/scale, sprintf('  Bruguet Range Solver Type: %.0f', bregTypes(i)), 'FontName', 'Calibri', 'FontSize', 10, 'HorizontalAlignment', 'left');
        text(0, (scale-(7*(i-1))-3)/scale, sprintf('  Distance: %.0f ft', dists(i)), 'FontName', 'Calibri', 'FontSize', 10, 'HorizontalAlignment', 'left');
        text(0, (scale-(7*(i-1))-4)/scale, sprintf('  True Airspeed: %.0f kts', velocs(i)), 'FontName', 'Calibri', 'FontSize', 10, 'HorizontalAlignment', 'left');
        text(0, (scale-(7*(i-1))-5)/scale, sprintf('  Average Tailwind: %.0f kts', vWind(i)), 'FontName', 'Calibri', 'FontSize', 10, 'HorizontalAlignment', 'left');        
        text(0, (scale-(7*(i-1))-6)/scale, sprintf('  Altitude: %.0f ft', alt(i)), 'FontName', 'Calibri', 'FontSize', 10, 'HorizontalAlignment', 'left');
        text(0, (scale-(7*(i-1))-7)/scale, sprintf('  SFC: %.2f', SFCs(i)), 'FontName', 'Calibri', 'FontSize', 10, 'HorizontalAlignment', 'left');
    end

    % Adjust positions based on current axis limits
    ax = gca;
    labelX = ax.XLim(2) + horOffset / 4;
    menuX = labelX + normalizedPosition2(3) / 4;
    txtBoxX = menuX + normalizedPosition2(3) / 2;
    labelText1 = uicontrol('Style', 'text', 'String', 'Segment Number:', 'Position', ...
        [labelX, 3*vertOffset/4, normalizedPosition2(3) / 2, normalizedPosition2(4) / 13], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    txtBox1 = uicontrol('Style', 'edit', 'Position', ...
        [labelX+2*normalizedPosition2(3) / 5, 3*vertOffset/4 + normalizedPosition2(4) / 26, normalizedPosition2(3) / 4, normalizedPosition2(4) / 26], ...
        'FontName', 'Calibri', 'FontSize', 14);
    labelText2 = uicontrol('Style', 'text', 'String', 'Edit Input:', 'Position', ...
        [labelX, vertOffset/25, normalizedPosition2(3) / 4, normalizedPosition2(4) / 13], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    variableNames1 = {'Bruguet Range Solver Type', 'Distance', 'Velocity', 'Tailwind','Altitude','SFC'};
    variableMenu1 = uicontrol(figSeg, 'Style', 'popupmenu', 'String', variableNames1, 'Position', ...
        [menuX, vertOffset/25 , normalizedPosition2(3) / 2, normalizedPosition2(4) / 13], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    txtBox2 = uicontrol('Style', 'edit', 'Position', ...
        [txtBoxX, vertOffset/25 + normalizedPosition2(4) / 30, normalizedPosition2(3) / 4, normalizedPosition2(4) / 26], ...
        'FontName', 'Calibri', 'FontSize', 14);
    axis off;
    UpdateButton = uicontrol('Style', 'pushbutton', 'String', 'Update Segment Inputs', ...
    'Position', [normalizedPosition1(3)/2,vertOffset/75,normalizedPosition1(3)/2,normalizedPosition1(4)/25], 'Callback', @updateSegVariables, ...
    'FontName', 'Calibri', 'FontSize', 12); 

        function updateSegVariables(~, ~)
            % Get selected variable name from dropdown menu
            selectedVariableIndex = get(variableMenu1, 'Value');
            selectedVariableName = variableNames1{selectedVariableIndex};
    
            % Get the new value from the edit text box
            i = str2double(txtBox1.String);
            newValue = str2double(txtBox2.String);
            
            % Check if input is valid
            if ~isnumeric(i) || ~isscalar(i) || i < 1 || i > segmts || mod(i, 1) ~= 0
                labelText = uicontrol('Style', 'text', 'String', 'Invalid Segment Number', ...
                    'Position', [horOffset/2, 0, normalizedPosition1(3)/3, normalizedPosition1(4)/27] ...
                    , 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 12);
                return;
            end

            % Update the selected variable
            if ~isnan(newValue)
                switch selectedVariableName
                    case 'Bruguet Range Solver Type'
                        bregTypes(i) = newValue;
                    case 'Distance'
                        dists(i) = newValue;
                    case 'Velocity'
                        velocs(i) = newValue;
                    case 'Altitude'
                        alt(i) = newValue;
                    case 'SFC'
                        SFCs(i) = newValue;
                    case 'Tailwind'
                        vWind(i) = newValue;              
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
            inputVariables = [segmts,Range,takeoffalt,runway_length,dh_dt,eta,W_pl,EWF,CD0,Clmax,wRF,WS,AR,osw,constraintscale];
            segmentVariables = [bregTypes',dists',velocs',vWind',alt',SFCs'];

            inputFigure1(inputVariables,segmentVariables,horsepower,constraintscale,carpetPlotVars)
            clc;
            labelText = uicontrol('Style', 'text', 'String', 'Segment Values Have Been Updated!', ...
                'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
        end

%% Display Mission Variables
    scale = 18;
    fig = figure('Position', normalizedPosition1, 'Toolbar', 'none', 'Menubar', 'none');
    set(fig, 'Resize', 'off');
    set(fig,'NumberTitle', 'off');
    % set(gcf,'color','w');
    title('Mission Inputs', 'FontName', 'Calibri', 'FontSize', 16);
    text(0, (scale-1)/scale, sprintf('Segments: %.0f', inputVariables(1)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-2)/scale, sprintf('Range: %.0f ft', inputVariables(2)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-3)/scale, sprintf('Takeoff Altitude: %.0f ft', inputVariables(3)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-4)/scale, sprintf('Runway Length: %.0f ft', inputVariables(4)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-5)/scale, sprintf('Climb Rate: %.2f ft/s', inputVariables(5)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-6)/scale, sprintf('Propellor Efficiency: %.2f', inputVariables(6)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-7)/scale, sprintf('Payload Weight: %.0f lbs', inputVariables(7)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-8)/scale, sprintf('Empty Weight Fraction: %.2f', inputVariables(8)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-9)/scale, sprintf('Parasitic Drag Coefficient: %.2f', inputVariables(9)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-10)/scale, sprintf('Max Lift Coefficient: %.2f', inputVariables(10)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-11)/scale, sprintf('Reserve Fuel: %.0f lbs', inputVariables(11)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-12)/scale, sprintf('Wing Loading: %.2f lbs/ft^2', inputVariables(12)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-13)/scale, sprintf('Aspect Ratio: %.2f', inputVariables(13)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-14)/scale, sprintf('Oswald Efficiency: %.2f', inputVariables(14)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-15)/scale, sprintf('Constraint Diagram Scale: %.3f', inputVariables(15)), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    text(0, (scale-16)/scale, sprintf('Carpet Plot Scale: %.3f', carpetscale), 'FontName', 'Calibri', 'FontSize', 14, 'HorizontalAlignment', 'left');
    axis off;
    
    labelText = uicontrol('Style', 'text', 'String', 'Edit Input:', 'Position', buttonPosition1, ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    variableNames = {'Segments', 'Range', 'Takeoff Altitude', 'Runway Length', ...
        'Climb Rate', 'Propellor Efficiency', 'Payload Weight', 'Empty Weight Fraction', 'Parasitic Drag Coefficient','Constraint Diagram Scale','Reserve Fuel', ...
        'Wing Loading', 'Aspect Ratio', 'Oswald Efficiency', 'Constraint Diagram Scale','Carpet Plot Scale'};
    variableMenu = uicontrol(fig, 'Style', 'popupmenu', 'String', variableNames, 'Position', buttonPosition2, ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    txtBox = uicontrol('Style', 'edit', 'Position', buttonPosition3, 'FontName', 'Calibri', 'FontSize', 14);
    UpdateButton = uicontrol('Style', 'pushbutton', 'String', 'Update Mission Inputs', ...
    'Position', [0,0,normalizedPosition1(3)/2,normalizedPosition1(4)/scale], 'Callback', @updateVariables, ...
    'FontName', 'Calibri', 'FontSize', 14); 
    OkButton = uicontrol('Style', 'pushbutton', 'String', 'Ok', ...
    'Position', [normalizedPosition1(3)/2,0,normalizedPosition1(3)/2,normalizedPosition1(4)/scale], 'Callback', @mainMenu, ...
    'FontName', 'Calibri', 'FontSize', 14); 
    
%% FUNCTIONS
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
                    case 'Segments'
                        segmts = newValue;
                    case 'Range'
                        Range = newValue;
                    case 'Takeoff Altitude'
                        takeoffalt = newValue;
                    case 'Runway Length'
                        runway_length = newValue;
                    case 'Climb Rate'
                        dh_dt = newValue;
                    case 'Propellor Efficiency'
                        eta = newValue;
                    case 'Payload Weight'
                        W_pl = newValue;
                    case 'Empty Weight Fraction'
                        EWF = newValue;
                    case 'Parasitic Drag Coefficient'
                        CD0 = newValue;
                    case 'Max Lift Coefficient'
                        Clmax = newValue;
                    case 'Reserve Fuel'
                        wRF = newValue;
                    case 'Wing Loading'
                        WS = newValue;
                    case 'Aspect Ratio'
                        AR = newValue;
                    case 'Oswald Efficiency'
                        osw = newValue;
                    case 'Constraint Diagram Scale'
                        constraintscale = newValue;
                    case 'Carpet Plot Scale'
                        carpetscale = newValue;
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
            inputVariables = [segmts,Range,takeoffalt,runway_length,dh_dt,eta,W_pl,EWF,CD0,Clmax,wRF,WS,AR,osw,constraintscale];
            segmentVariables = [bregTypes',dists',velocs',vWind',alt',SFCs'];
    
            inputFigure1(inputVariables,segmentVariables,horsepower,constraintscale,carpetPlotVars,carpetscale)
            clc;
            labelText = uicontrol('Style', 'text', 'String', 'Mission Values Have Been Updated!', ...
                'Position', textPosition1, 'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
        end
    
    function mainMenu(~,~)
    try
        %% Test Inputs

        close all; % Close all open figures
        inputVariables = [segmts, Range, takeoffalt, runway_length, dh_dt, eta, W_pl, EWF, CD0, Clmax, wRF, WS, AR, osw, constraintscale];
        segmentVariables = [bregTypes', dists', velocs', vWind', alt', SFCs'];
        breguetSegmentTester(1, horsepower, inputVariables, segmentVariables,carpetPlotVars,carpetscale);

    catch ME
        % If an error occurs, display an error message
        close all;
        errorMessage = sprintf('Error: %s\n%s', ME.identifier, ME.message);
        errFig = figure('Name', 'Error','Menubar', 'none','NumberTitle', 'off', 'Position', errorFigurePosition);
        set(errFig,'Toolbar', 'none')
        set(errFig, 'Resize', 'off');
        set(errFig,'NumberTitle', 'off');
        uicontrol('Style', 'text', 'String', errorMessage, 'Position', [0,3*errorFigurePosition(4)/10,errorFigurePosition(3), errorFigurePosition(4)/2], 'HorizontalAlignment', 'left', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [1, 0.8, 0.8]);
        uicontrol('Style', 'text', 'String', 'There was an error, please adjust your inputs!', 'Position', ...
        [0, 8*errorFigurePosition(4)/10, errorFigurePosition(3), errorFigurePosition(4)/6], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
         okButton = uicontrol('Style', 'pushbutton', 'String', 'OK', ...
        'Position', [0,0,errorFigurePosition(3)/2,errorFigurePosition(4)/4], 'Callback', @backtoInputs, ...
        'FontName', 'Calibri', 'FontSize', 16);
    end
    end

        function backtoInputs(~,~)
            close all; % Close all open figures
            inputFigure1(inputVariables,segmentVariables,horsepower,constraintscale,carpetPlotVars,carpetscale)
        end

end