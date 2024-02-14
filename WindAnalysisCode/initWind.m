%% AERO 444 - Senior Design 2 - Route Wind Analysis Tool

%Team E:
%Anthony Guerra
%Chris Sheehan
%Ryan White

%Setup / Data Initialization Function
function initWind()

    %recognize global variables altered in initialization
    global WindX
    global WindY
    global WindTime
    global WindPAlt
    
    global speedU
    global speedV
    
    %Purpose: creates variable data in MATLAB Workspace before running
    %performance/get function calls

    %load 4 dimensional arrays of U and V data for last 5 years
    WindX = ncread("DailyU2019to24.nc","X");
    WindY = ncread("DailyU2019to24.nc","Y");
    WindTime = ncread("DailyU2019to24.nc","T");
    WindTime = datestr(double(WindTime) + 711493);
    WindPAlt = ncread("DailyU2019to24.nc","P");
    
    %load u and v components of wind for last 5 years
    speedU = ncread("DailyU2019to24.nc","u");
    speedV = ncread("DailyV2019to24.nc","v");

end


%Call Data Function
function [u,v] = getWind() %inputs location in deg, date in ____ format, and alt

    %turn degree inputs into indexes in X and Y arrays
    %turn date format into indexes in T
    %turn PAlt into index in P
    
    %interpolation to get precise u and v
    
    %return u and v

end

