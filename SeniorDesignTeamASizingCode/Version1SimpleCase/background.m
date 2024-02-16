function [] = background()
    % Create a background uifigure
    backgroundFigure = figure('Name', 'Background Figure', 'Color', 'blue', ...
        'HandleVisibility', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
        'Resize', 'off', 'WindowStyle', 'normal', 'ButtonDownFcn', @backgroundClickCallback);

    % Set the position of the background figure (adjust as needed)
    screenSize = get(0, 'ScreenSize');
    backgroundFigure.Position = screenSize;

    % Create a larger button on the top of the background figure to push the figure to the back
    buttonWidth = 150;
    buttonHeight = 50;
    pushButton = uicontrol(backgroundFigure, 'Style', 'pushbutton', 'String', 'Push to Back', ...
        'Position', [(screenSize(3) - buttonWidth) / 2, screenSize(4) - buttonHeight - 20, buttonWidth, buttonHeight], ...
        'Callback', @pushToBackCallback, 'FontSize', 14);

    % Callback function for the button
    function pushToBackCallback(~, ~)
        % Set WindowStyle to 'normal' to push the background figure to the back
        set(backgroundFigure, 'WindowStyle', 'normal');
    end

    % Callback function to handle click on the background figure
    function backgroundClickCallback(~, ~)
        % Temporarily make the background figure visible
        set(backgroundFigure, 'HandleVisibility', 'on');
        % Pause for a short duration to allow the figure to become visible
        pause(0.1);
        % Set the HandleVisibility back to 'off' to hide the figure behind others
        set(backgroundFigure, 'HandleVisibility', 'off');
    end
end



