function [value] = missionConversions(value, conversionType)
    % This function converts the input value to the desired output value
    % based on the conversion type.
    % Inputs:
    % value: the value to be converted
    % conversionType: the type of conversion to be done (string)
    % Outputs:
    % value: the converted value

    % Structure that holds the conversion functions

    % Conversion functions
    conversions.ftToNM = @(value) value * 12 * 2.54 / 100 / 1852;
    conversions.NMToft = @(value) value * 6076.12;


    % Perform the conversion
    if isfield(conversions, conversionType)
        value = conversions.(conversionType)(value);
    else
        error("Conversion type not found");
    end
end
