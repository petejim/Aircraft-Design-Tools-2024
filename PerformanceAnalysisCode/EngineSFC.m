function [sfc] = EngineSFC(P,AdjEngineDeck)

% INPUTS:
% P - power in horsepower (already adjusted by eta)
% AdjEngineDeck - altitude adjusted engine data matrix

% OUTPUTS
% sfc - specific fuel consumption in lbs/hr/hp


solve = abs(AdjEngineDeck(:,1) - P);
[~,I] = min(solve);
sfc = AdjEngineDeck(I,2);

end