close all; clear; clc;

dates = generateDates('30-Dec-2020', 10);

disp(dates);


function dates = generateDates(startDate, numDays)
    % Generates a consecutive cell list of dates starting from the given date

    % Convert the start date to a datetime
    startDate = datetime(startDate, 'InputFormat', 'dd-MMM-yyyy');
    
    % Generate a vector of dates
    dates = startDate + caldays(0:numDays-1);
    
    % Convert the dates to strings
    dates = cellstr(datestr(dates, 'dd-mmm-yyyy'));
end