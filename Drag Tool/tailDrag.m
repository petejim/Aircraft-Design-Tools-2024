function [Cl, Cd0, Cdi] = tailDrag(t, c, e, S, b)

%==========================================================================
% INPUTS
% t = Maximum Thickness in %
% c = Design Cl multiplied by 10
% e = oswald efficiency
% S = wing planform area? 
% b = wing span
% W = aircraft weight (which one?) 
% speeds = vector of speeds to find Cd at 
% alt = operating altitude
% t and c combinations are only found for combination lying near availible 
% data
%==========================================================================

% Load in All the TOWS Data
load('NACA6data.mat');
NACA63 = rmfield(NACA63, "N6210");

fn1 = fieldnames(NACA63);
c1 = 1;
c2 = 1;

%Constant for how much to drop the function and how wide the drop it
width = [6,9,12,15,18,21; 0.13, 0.28, 0.3, 0.44, 0.5, 0.6]';  %Thickness Dependant

%Find all the airfoils within the range of thicknesses (+/- 2%)
for i = 1:length(fn1)
    if NACA63.(fn1{i}).thick >= t-2 && NACA63.(fn1{i}).thick <= t+2
        x(c1) = NACA63.(fn1{i});
        c1 = c1+1;
    end
end

%Out of those airfoils find the ones within the right designed Cl (+/- 0.2)
for j = 1:length(x)
    if x(j).camb >= c-1 && x(j).camb <= c+1
        y(c2) = x(j);
        c2 = c2+1;
    end
end

%Make a data table of all the data from the selected airfoils
for k = 1:length(y)
    fd(:,k) = y(k).data{:,2};
end

numFoils = size(fd);

%Depending on how many airfoils are found, interpolate or not
if numFoils(2) == 1

    yfit = fd;
    xfit = y.data{:,1};
  
elseif numFoils(2) == 2

    % Find the weight to put on the interpolation
    if y(1).thick == y(2).thick

        wt = 1/((y(1).camb+y(2).camb)/c);

    elseif y(1).camb == y(2).camb

        wt = 1/((y(1).thick+y(2).thick)/c);

    end

    xfit = y(1).data{:,1};
    yfit = iterpol(fd, wt, 0)';

elseif numFoils(2) == 3

    xfit = y(2).data{:,1};
    yfit = y(2).data{:,2};

elseif numFoils(2) == 4

    if y(1).thick == y(2).thick

        wt1 = 1/((y(1).camb+y(2).camb)/c);

    elseif y(1).camb == y(2).camb

        wt1 = 1/((y(1).thick+y(2).thick)/c);

    end

    if y(3).thick == y(4).thick

        wt2 = 1/((y(3).camb+y(4).camb)/c);

    elseif y(3).camb == y(4).camb

        wt2 = 1/((y(3).thick+y(4).thick)/c);

    end

    y1 = iterpol(fd(:,1:2), wt1, 0)';
    y2 = iterpol(fd(:,3:4), wt2, 0)';
    ydat = [y1, y2];
    wt = mean([wt1,wt2]);
    yfit = iterpol(ydat, wt, 0)';
    xfit = y(1).data{:,1};

end

%Interpolate the width and depth
wid = iterpol(width, t, 1);
range = [(c/10)-wid (c/10)+wid];

c2 = 1;

% Sort Data for NaN and for the width and dpeth
for p = 1:length(yfit)
    if (xfit(p) < range(1) || xfit(p) > range(2)) && isnan(yfit(p)) == 0
        xpoly(c2) = xfit(p);
        ypoly(c2) = yfit(p);
        c2 = c2+1;
    end
end

% Poly fit
p = polyfit(xpoly, ypoly, 2);
x = linspace(-1, 1.4, 50);
y = polyval(p, x);
dep = min(y)-min(yfit);

% Add in the drag drop
for o = 1:length(y)
    if x(o) > range(1) && x(o) < range(2) 
        y(o) = y(o)-dep;
    end
end

% Cl = x;
% Cd0 = y;
% Cdi = 0;

Cl = 0;

r = 1;

while x(r) < Cl
    r = r+1;
end

Cd0 = y(r);

AR = b^2/S;

Cdi = Cl.^2./(pi*AR*e);



    