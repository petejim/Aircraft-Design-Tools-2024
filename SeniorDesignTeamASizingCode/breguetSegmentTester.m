function [] = breguetSegmentTester(run,hp,inputVariables,segmentVariables,carpetPlotVars,carpetscale)
% Inputs Variables, Calls Other Functions

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

%% Functions
    % Run Input Figure Automatically
    if run == 0
        carpetPlotVars = 0;
        inputFigure1(inputVariables,segmentVariables,0,0,carpetPlotVars,carpetscale);
    else
        % Fix Range if Broken
        if sum(dists) ~= Range
            dists = Range / segmts + zeros(segmts,1);
            segmentVariables(:,2) = dists;
        end

        [Result] = weightFromSegments(bregTypes,dists,velocs,vWind,...
            alt,SFCs,W_pl,wRF,WS,EWF,eta,AR,osw,CD0);
        W_fval = (Result(1) - (Result(1) * EWF + W_pl + wRF));
        W_eval = Result(1)-W_fval-W_pl;

        % Display Results
        MTOW = Result(1);
        fFuel = Result(2:end,1);
        
        % "Hand Calc" to check if calculated fuel fraction acheives the desired range
        [range,x,totT,t,avgV] = rangeFromFuelFractions(bregTypes,MTOW,fFuel,dists,...
            velocs,vWind,alt,SFCs,WS,EWF,eta,AR,osw,CD0);
        
        % Plot Segment Results
        [xMission,vTASMission,vGrndMission,wMission,rhoMission,CLMission,LDMission] = ...
            missionProfileSegments(10,[1,1],bregTypes,MTOW,fFuel,...
            dists,velocs,vWind,alt,SFCs,WS,EWF,eta,AR,osw,CD0);

        % Constraint Diagram
        cruisev = max(velocs);
        LD = min(LDMission);
        cruisealt = min(alt);
        [W_Sval,W_Pval,P_Wval,minhp,horsepower] = constraintDiagramFunction1(1,constraintscale,cruisealt, ...
            takeoffalt,cruisev,runway_length,dh_dt,LD,Clmax,CD0,eta,hp,MTOW,inputVariables);

%         % Carpet Plots: Comment the line below to turn off
%         [carpetPlotVars] = carpetPlotFunction1(hp,inputVariables,segmentVariables,carpetPlotVars,carpetscale);

        % Display Results
        displayResults1(EWF,W_pl,range,eta,Clmax,CD0, ...
            MTOW,W_eval,W_fval,W_Sval,W_Pval,P_Wval,hp,horsepower,inputVariables,segmentVariables,constraintscale,totT,carpetPlotVars,carpetscale)

    end
end


