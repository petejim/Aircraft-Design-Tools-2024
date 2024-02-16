function [] = SizingToolInputs(run,hp,inputVariables)
%% PLOT FORMATTING

% Carpet Plot Ranges
LDmin = 20; % Min L/D line
LDmax = 30; % Max L/D line
SFCmin = .3; % Min SFC line
SFCmax = .425; % Max SFC line
EWFmin = .20; % Min EWF line
EWFmax = .30; % Max EWF line

%% FUNCTIONS 

% FUNCTION VARIABLES
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

constraintinputs = [constraintscale,takeoffalt,runway_length,dh_dt];

% Run Input Figure Automatically
if run == 0
    [inputVariables,hp] = inputFigure(inputVariables,0);
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
else
    % CARPET PLOT FUNCTION
    [W_toval, W_eval, W_fval] = carpetPlotFunction(1,carpetscale,LD,SFC,EWF,eta, ...
        LDmin,LDmax,SFCmin,SFCmax,EWFmin,EWFmax,W_pl,Range,wind,cruisev,constraintscale,hp,inputVariables);
    
    % CONSTRAINT DIAGRAM FUNCTION
    [W_Sval,W_Pval,P_Wval,minhp] = constraintDiagramFunction(1,constraintscale,cruisealt, ...
        takeoffalt,cruisev,runway_length,dh_dt,LD,Clmax,CD0,eta,hp,W_toval);
    
    % DISPLAY FUNCTION
    displayResults(LD,SFC,EWF,W_pl,cruisealt,cruisev,Range,eta,Clmax,CD0, ...
        W_toval,W_eval,W_fval,W_Sval,W_Pval,P_Wval,hp,constraintinputs,minhp,inputVariables);
end

end