function [carpetPlotVars] = carpetPlotFunction1(horsepower,inputVariables,segmentVariables,carpetPlotVars,carpetscale)
    % Plot Carpet Plot
    
    % Display Position Variables
    screenSize = get(0, 'ScreenSize');
    horOffset = screenSize(3)/100;
    vertOffset = screenSize(4)/25;
    
    normalizedPosition = [2*screenSize(3)/3 + horOffset, screenSize(4)/2 - vertOffset/2, screenSize(3)/3 - 2*horOffset, (screenSize(4)/2 - vertOffset)/4];
    normalizedPosition2 = [2*screenSize(3)/3 + horOffset, screenSize(4)/2+(screenSize(4)/2 - vertOffset)/3, screenSize(3)/3 - 2*horOffset, 2*(screenSize(4)/2 - vertOffset)/3];
    
    updateButtonPosition = [0, vertOffset/25, normalizedPosition(3)/2-horOffset/10, normalizedPosition(4)/4];
    saveFunctionPosition = [normalizedPosition(3)/2, vertOffset/25, normalizedPosition(3)/2-horOffset/10, normalizedPosition(4)/4];
    saveFigurePosition1 = [0,screenSize(4)/2,screenSize(3)/4,screenSize(4)/7];
    textPosition1 = [horOffset,vertOffset/5,normalizedPosition(3),normalizedPosition(4)/12];
    
    % Data Storage
    if carpetPlotVars == 0
        variable1 = 1; % EWF
        minVariable1 = .18;
        maxVariable1 = .28;
        numLinesVariable1 = 5;

        variable2 = 3; % Wing Loading
        minVariable2 = 30;
        maxVariable2 = 40;
        numLinesVariable2 = 6;
        
        % Store Variables
        carpetPlotVars = zeros(1,8);
        carpetPlotVars(1) = variable1;
        carpetPlotVars(2) = minVariable1;
        carpetPlotVars(3) = maxVariable1;
        carpetPlotVars(4) = numLinesVariable1;
        carpetPlotVars(5) = variable2;
        carpetPlotVars(6) = minVariable2;
        carpetPlotVars(7) = maxVariable2;
        carpetPlotVars(8) = numLinesVariable2;
        variable1Name = var2Name(variable1);
        variable2Name = var2Name(variable2);
    else
        variable1 = carpetPlotVars(1);
        minVariable1 = carpetPlotVars(2);
        maxVariable1 =carpetPlotVars(3);
        numLinesVariable1 = carpetPlotVars(4);
        variable2 = carpetPlotVars(5);
        minVariable2 = carpetPlotVars(6);
        maxVariable2 = carpetPlotVars(7);
        numLinesVariable2 = carpetPlotVars(8);
        variable1Name = var2Name(variable1);
        variable2Name = var2Name(variable2);
    end
    
    % Figure
    figDisplay = figure('Position', normalizedPosition, 'Toolbar', 'none', 'Menubar', 'none');
    set(figDisplay, 'Resize', 'off');
    set(figDisplay,'NumberTitle', 'off');
    axis off;
    scale = 14;

    text(.5, (scale-1)/scale, sprintf('CARPET PLOT: %s & %s', variable1Name, variable2Name), 'FontName', 'Calibri', 'FontSize', 16, 'HorizontalAlignment', 'center');



%% Display Variables
    
    % Variable 1
    labelText1_1 = uicontrol('Style', 'text', 'String', 'Variable 1:', 'Position', ...
        [horOffset/2, 5*normalizedPosition(4) / 10, normalizedPosition(3) / 6, normalizedPosition(4) / 4], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14, 'ForegroundColor', 'red');
    variableNames1 = {'EWF', 'Parasitic Drag Coefficient','Wing Loading', 'Aspect Ratio'};
    variableMenu1 = uicontrol(figDisplay, 'Style', 'popupmenu', 'String', variableNames1, 'Position', ...
        [horOffset/2 + normalizedPosition(3) / 6, 5*normalizedPosition(4) / 10,  normalizedPosition(3) / 4,  normalizedPosition(4) / 4], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14); 
    labelText1_2 = uicontrol('Style', 'text', 'String', 'Limits:', 'Position', ...
        [horOffset + 2 * normalizedPosition(3) / 5, 5*normalizedPosition(4) / 10, normalizedPosition(3) / 6, normalizedPosition(4) / 4], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    txtBox1_1 = uicontrol('Style', 'edit', 'Position', ...
        [3*horOffset/2 + normalizedPosition(3) / 2, 5*normalizedPosition(4) / 10 + normalizedPosition(4) / 12, normalizedPosition(3) / 12, normalizedPosition(4) / 6], ...
        'FontName', 'Calibri', 'FontSize', 14);
    txtBox1_2 = uicontrol('Style', 'edit', 'Position', ...
        [horOffset + 11 * normalizedPosition(3) / 18, 5*normalizedPosition(4) / 10 + normalizedPosition(4) / 12, normalizedPosition(3) / 12, normalizedPosition(4) / 6], ...
        'FontName', 'Calibri', 'FontSize', 14);
    labelText1_3 = uicontrol('Style', 'text', 'String', '# of Lines:', 'Position', ...
        [horOffset + 7 * normalizedPosition(3) / 10, 5*normalizedPosition(4) / 10, normalizedPosition(3) / 6, normalizedPosition(4) / 4], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    txtBox1_3 = uicontrol('Style', 'edit', 'Position', ...
        [9 * normalizedPosition(3) / 10, 5*normalizedPosition(4) / 10 + normalizedPosition(4) / 12, normalizedPosition(3) / 12, normalizedPosition(4) / 6], ...
        'FontName', 'Calibri', 'FontSize', 14);

    % Set the Value property based on the variable1 value
    variableMenu1.Value = find(strcmp(variableNames1, variable1Name));
    txtBox1_1.String = num2str(minVariable1);
    txtBox1_2.String = num2str(maxVariable1);
    txtBox1_3.String = num2str(numLinesVariable2);

    % Variable 2
    labelText2_1 = uicontrol('Style', 'text', 'String', 'Variable 2:', 'Position', ...
        [horOffset/2, 2*normalizedPosition(4) / 10, normalizedPosition(3) / 6, normalizedPosition(4) / 4], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14,'ForegroundColor', 'blue');
    variableNames2 = {'EWF', 'Parasitic Drag Coefficient','Wing Loading', 'Aspect Ratio'};
    variableMenu2 = uicontrol(figDisplay, 'Style', 'popupmenu', 'String', variableNames1, 'Position', ...
        [horOffset/2 + normalizedPosition(3) / 6, 2*normalizedPosition(4) / 10,  normalizedPosition(3) / 4,  normalizedPosition(4) / 4], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14); 
    labelText2_2 = uicontrol('Style', 'text', 'String', 'Limits:', 'Position', ...
        [horOffset + 2 * normalizedPosition(3) / 5, 2*normalizedPosition(4) / 10, normalizedPosition(3) / 6, normalizedPosition(4) / 4], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    txtBox2_1 = uicontrol('Style', 'edit', 'Position', ...
        [3*horOffset/2 + normalizedPosition(3) / 2, 2*normalizedPosition(4) / 10 + normalizedPosition(4) / 12, normalizedPosition(3) / 12, normalizedPosition(4) / 6], ...
        'FontName', 'Calibri', 'FontSize', 14);
    txtBox2_2 = uicontrol('Style', 'edit', 'Position', ...
        [horOffset + 11 * normalizedPosition(3) / 18, 2*normalizedPosition(4) / 10 + normalizedPosition(4) / 12, normalizedPosition(3) / 12, normalizedPosition(4) / 6], ...
        'FontName', 'Calibri', 'FontSize', 14);
    labelText2_3 = uicontrol('Style', 'text', 'String', '# of Lines:', 'Position', ...
        [horOffset + 7 * normalizedPosition(3) / 10, 2*normalizedPosition(4) / 10, normalizedPosition(3) / 6, normalizedPosition(4) / 4], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
    txtBox2_3 = uicontrol('Style', 'edit', 'Position', ...
        [9 * normalizedPosition(3) / 10, 2*normalizedPosition(4) / 10 + normalizedPosition(4) / 12, normalizedPosition(3) / 12, normalizedPosition(4) / 6], ...
        'FontName', 'Calibri', 'FontSize', 14);

    % Set the Value property based on the variable2 value
    variableMenu2.Value = find(strcmp(variableNames2, variable2Name));
    txtBox2_1.String = num2str(minVariable2);
    txtBox2_2.String = num2str(maxVariable2);
    txtBox2_3.String = num2str(numLinesVariable1);

    updatebtn = uicontrol('Style', 'pushbutton', 'String', 'Update Figures', ...
        'Position', updateButtonPosition, 'Callback', @updateCarpetVariables, ...
        'FontName', 'Calibri', 'FontSize', 14); 
    savebtn = uicontrol('Style', 'pushbutton', 'String', 'Save Figures', ...
        'Position', saveFunctionPosition, 'Callback', @saveAllFiguresAsSVG, ...
        'FontName', 'Calibri', 'FontSize', 14); 

%% Carpet Plot
    
    % Position Variables
    figDisplay = figure('Position', normalizedPosition2, 'Toolbar', 'none', 'Menubar', 'none');
    set(figDisplay, 'Resize', 'off');
    set(figDisplay,'NumberTitle', 'off');
    dcCarpet();
    grid minor;
    
    function[] = dcCarpet()
        % Inputs Variables
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
     
        % Carpet variable inputs
        lim1low = minVariable1;
        lim1up = maxVariable1;
        lim2low = minVariable2;
        lim2up = maxVariable2;
        lineNum1 = numLinesVariable1;
        lineNum2 = numLinesVariable2;
        res = 4;
        varChoice1 = variable1Name;
        varChoice2 = variable2Name;
    
        inputVar1 = linspace(lim1low,lim1up,(lineNum1 * res)+1);
        inputVar2 = linspace(lim2low,lim2up,(lineNum2 * res)+1);
        offset = .5;
    
        [X_1,Y_2] = meshgrid(inputVar1,inputVar2);
        z = X_1 .* 0;
         
        for i = 1:length(inputVar1)
                switch varChoice1
                    case 'Wing Loading'
                        WS = inputVar1(i); 
                    case 'Aspect Ratio' 
                        AR = inputVar1(i);
                    case 'Parasitic Drag Coefficient'
                        CD0 = inputVar1(i);
                    case 'EWF'
                        EWF = inputVar1(i);
                end
            for j = 1:length(inputVar2)
                switch varChoice2
                    case 'Wing Loading'
                        WS = inputVar2(j);
                    case 'Aspect Ratio'
                        AR = inputVar2(j);
                    case 'Parasitic Drag Coefficient'
                        CD0 = inputVar2(j);
                    case 'EWF'
                        EWF = inputVar2(j);          
                end
         
                [Result] = weightFromSegments(bregTypes,dists,velocs,vWind,alt,SFCs,...
                    W_pl,wRF,WS,EWF,eta,AR,osw,CD0);
         
                z(j,i) = Result(1);
         
            end
        end
        
        carpetMod2(X_1,Y_2,z,offset,3,'r','b');
        ylabel('MTOW (lbs)', 'FontSize', 16, 'FontName', 'Calibri');
        ylim([0,carpetscale])

    end


%% Update Variables 

    function updateCarpetVariables(~,~)
        selectedVariableIndex = variableMenu1.Value;
        variable1Name = variableNames1{selectedVariableIndex};
        variable1 = name2Var(variable1Name);
        
        minVariable1 = str2double(get(txtBox1_1, 'String'));
        maxVariable1 = str2double(get(txtBox1_2, 'String'));
        numLinesVariable1 = str2double(get(txtBox1_3, 'String'));

        selectedVariableIndex = variableMenu2.Value;
        variable2Name = variableNames2{selectedVariableIndex};
        variable2 = name2Var(variable2Name);

        minVariable2 = str2double(get(txtBox2_1, 'String'));
        maxVariable2 = str2double(get(txtBox2_2, 'String'));
        numLinesVariable2 = str2double(get(txtBox2_3, 'String'));

        % Store Variables
        carpetPlotVars(1) = variable1;
        carpetPlotVars(2) = minVariable1;
        carpetPlotVars(3) = maxVariable1;
        carpetPlotVars(4) = numLinesVariable1;
        carpetPlotVars(5) = variable2;
        carpetPlotVars(6) = minVariable2;
        carpetPlotVars(7) = maxVariable2;
        carpetPlotVars(8) = numLinesVariable2;
        
        close all;
        breguetSegmentTester(1,horsepower,inputVariables,segmentVariables,carpetPlotVars,carpetscale)

    end

%% Save Plots
    function saveAllFiguresAsSVG(~,~)  
        uploadNewSave;
    
        % Create New Save
        function uploadNewSave(~,~)
            % Get all open figures
            figHandles = findall(0, 'Type', 'figure');
            h = waitbar(0, 'Please wait...');
    
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
        axis off;
        uicontrol('Style', 'text', 'String', 'Your figures were saved to the Saved Data folder!', 'Position', ...
        [0, 2*saveFigurePosition1(4)/5, saveFigurePosition1(3), saveFigurePosition1(4)/4], ...
        'HorizontalAlignment', 'left', 'FontName', 'Calibri', 'FontSize', 14);
        newSaveButton = uicontrol('Style', 'pushbutton', 'String', 'OK', ...
        'Position', [0,0,saveFigurePosition1(3)/2,saveFigurePosition1(4)/4], 'Callback', @mainMenu, ...
        'FontName', 'Calibri', 'FontSize', 16);
    
        function mainMenu(~,~)
            close all; % Close all open figures
            breguetSegmentTester(1,horsepower,inputVariables,segmentVariables,carpetPlotVars,carpetscale);
        end
    end
    
    end
    
    function [Name] = var2Name(var)
        if var == 1
            Name = 'EWF';
        end
        if var == 2
            Name = 'Parasitic Drag Coefficient';
        end
        if var == 3
            Name = 'Wing Loading';
        end   
        if var == 4
            Name = 'Aspect Ratio';
        end               
    end

    function [var] = name2Var(Name)
        if strcmpi(Name, 'EWF')
            var = 1;
        elseif strcmpi(Name, 'Parasitic Drag Coefficient')
            var = 2;
        elseif strcmpi(Name, 'Wing Loading')
            var = 3;
        elseif strcmpi(Name, 'Aspect Ratio')
            var = 4;
        else
            % Handle the case where Name does not match any known strings
            var = -1;  % or any other value indicating an unknown variable
        end          
    end

end

function[] = carpetMod2(x1, x2, y, offset, nref, linspec1, linspec2, varargin)
%CARPET Plots a carpet plot with two independent and one dependent variable.
%   h = carpet(x1, x2, y, offset) generates a carpet plot with
%   independent variables x1 & x2 and dependent variable y.  The plot is
%   created using a cheater axis generated by the equation:
%
%   xcheat = x1 + x2 * offset.
%
%   x1 & x2 may be vectors, or they may be matrices as generated by
%   MESHGRID.  x1, x2, & y should be arranged such that they could be
%   plotted with SURF(x1,x2,y).
%
%   Handles to the resulting carpet plot curves are returned in h.
%
%   Setting nonzero nref will cause lines in the carpet plot to be skipped.
%   This can be used to create smooth curves in the carpet plot without
%   excess clutter.  Default nref = 0.  The same value of nref is applied
%   to both x1 and x2 directions.  Refined vectors can be created using
%   REFVEC.
%
%   linspec1 specifies the line style for the x1=constant lines.  If it is
%   not specified, it defaults to 'k'.
%
%   linspec2 specifies the line style for the x2=constant lines.  If it is
%   not specified, it defaults to linspec1.
%
%   Any additional arguments passed to CARPET are passed to the plot
%   command.
%
%   See also CARPETCONVERT, CARPETCONTOURCONVERT, REFVEC.
 
%   Rob McDonald
%   ramcdona@calpoly.edu 
%   19 February 2013 v. 1.0
 
if( nargin < 5 )
  nref = 0;
end
 

%   Rob McDonald 
%   ramcdona@calpoly.edu  
%   19 February 2013 v. 1.0

if( nargin < 5 )
  nref = 0;
end
% Handle default line styles.
if( nargin < 6 )
  linspec1 = 'k';
end
if( nargin < 7 )
  linspec2 = linspec1;
end
 

if( nargin < 7 )
  linspec2 = linspec1;
end

% If input is not matrix similar to meshgrid, make it so.
if( isvector(x1) && isvector(x2) )
  [X1,X2] = meshgrid( x1, x2 );
else
  X1 = x1;
  X2 = x2;
end
 
% Calculate the cheater axis.
Xcheat = X1 + X2 * offset;
 
% Plot the carpet plot lines.
    % Plot the carpet plot lines with modified linewidth
    hold on
    plot(Xcheat(1:nref+1:end, :)', y(1:nref+1:end, :)', 'LineWidth', 1.5, 'Color', linspec1, varargin{:});
    plot(Xcheat(:, 1:nref+1:end), y(:, 1:nref+1:end), 'LineWidth', 1.5, 'Color', linspec2, varargin{:});


% % Calculate the cheater axis.
% Xcheat = X1 + X2 * offset;
% 
% % Plot the carpet plot lines.
% hold on
% plot(Xcheat(1:nref+1:end,:)', y(1:nref+1:end,:)',...
%     varargin{:}, Color=linspec1)
% plot(Xcheat(:,1:nref+1:end), y(:,1:nref+1:end), ...
%     varargin{:}, Color=linspec2);
% Hide the X-axis and turn off the box.
ca = gca;
set(ca,'XTick',[])
box off
set(ca,'XColor',[1,1,1])

end