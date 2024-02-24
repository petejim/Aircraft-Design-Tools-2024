function [AdjEngineDeck] = ChangeEngineAlt(EngineType, SeaLevelMatrix, MinSFC, Altitude, ServiceCeiling, n)
%-----------------Rev. Date 2/2/2024 @ 2:20 PM---------------------------
%Change sea level engine deck to reflect change in altitudes
%EngineType = String that specifies diesel or gas type engine
%             'G' = Gasoline
%             'D' = Diesel
%SeaLevelMatrix = Engine Deck based on function BuildEngineDeck
%MinSFC = Minimum Desired SFC (lb/hp-hr)
%Altitude = Desired Altitude (ft)
%n = number of points
%
%
%AdjEngineDeck returns a nx2 matrix 
%First Column is Brake HP 
%Second Column is SFC in lb/hp-hr
%-------------------------------------------------------

% Sea level conditions
t_sealevel = 288.15; % Kelvin
p_sealevel = 2116.23; % lb-f/ft^2
rho_sealevel = 0.00237717; % slug/ft^3

if Altitude - ServiceCeiling < 0 
    AdjEngineDeck = SeaLevelMatrix;
    return; 
else
    Altitude = Altitude - ServiceCeiling; 
end

% Local atmospheric conditions
T = 0; % Offset
unit = "IMP";
[Tstd, ~, rhostd, ~] = standatm(Altitude, T, unit);


Density_ratio = (rhostd/rho_sealevel);

%Find Max Power and Min SFC
MaxPower = max(SeaLevelMatrix(:,1)); 


%Adjust Power based on air density ratio


    Power_Ratio = 1.132*(Density_ratio)-.132;


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
PercentBHP  = linspace(20, Power_Ratio * 100, n); 
PercentSFC = zeros(1,n(end));
for i = 1:n(end)
   
    if PercentBHP(i) <= 70
        
        PercentSFC(i) = func1(PercentBHP(i));
        
    else
        
        PercentSFC(i) = func2(PercentBHP(i)); 
        
    end
end

%Convert to BHP using desired max BHP
BHP = PercentBHP * MaxPower / 100; 

%Convert to SFC using desired min SFC
SFC = PercentSFC * MinSFC / 100; 

%Concatenate the vectors 
AdjEngineDeck = [BHP', SFC';]; 



end

