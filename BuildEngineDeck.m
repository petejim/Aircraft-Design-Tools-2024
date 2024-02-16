function [SeaLevelMatrix] = BuildEngineDeck(EngineType, MinSFC, MaxBHP, n)
%-----------------Rev. Date 2/2/2024 @ 2:20 PM---------------------------
%Create approximate engine deck for desired performance metrics
%EngineType = String that specifies diesel or gas type engine
%             'G' = Gasoline
%             'D' = Diesel
%MinSFC = lowest desired SFC for the engine to run at
%MaxBHP = Maximum Brake Horsepower of the engine
%n = number of points desired for the 
%
%
%SeaLevelMatrix returns a nx2 matrix 
%First Column is Brake HP 
%Second Column is SFC in lb/hp-hr
%-------------------------------------------------------

if EngineType == 'G'
    %Constants for approximating Engine Curve
    A = 0.03;
    B = -140 * A;
    C = 4900 * A + 100; 

    A2 = 2/3; 
    B2 = 160/3;
    
elseif EngineType == 'D'   
    %Constants for approximating Engine Curve
    A = 0.005179485644285;
    B = -140 * A;
    C = 4900 * A + 100; 

    A2 = 1/3; 
    B2 = 230/3;    
end

    func1 =@(x) A * x.^2 + B * x + C;
    func2 =@(x) A2 * x + B2;

    %Find Percent SFC and BHP
    PercentBHP  = linspace(20, 100, n); 
    PercentSFC = zeros(1,n);
    for i = 1:n
   
        if PercentBHP(i) <= 70
        
            PercentSFC(i) = func1(PercentBHP(i));
        
        else
        
            PercentSFC(i) = func2(PercentBHP(i)); 
        
        end
    end
 
  

%Convert to BHP using desired max BHP
BHP = PercentBHP * MaxBHP / 100; 

%Convert to SFC using desired min SFC
SFC = PercentSFC * MinSFC / 100; 

%Concatenate the vectors 
SeaLevelMatrix = [BHP', SFC';]; 

end

