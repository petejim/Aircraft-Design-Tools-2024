function [] = engineFunc(obj, path)
    % Function sets the engine data for the aircraft object
    % path: path to the engine data spreadsheet (assumes .xlsx first column is power, second column is SFC, third column is RPM)
    engineData = table2array(load(path).ans);
    obj.engMatSL = engineData(:,1:2);

end