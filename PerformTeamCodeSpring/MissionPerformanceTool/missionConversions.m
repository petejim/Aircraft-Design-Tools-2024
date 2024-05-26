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

    %% Distance
    conversions.ftToNM = @(value) value * 12 * 2.54 / 100 / 1852;
    conversions.NMToft = @(value) value / conversions.ftToNM(1);

    %% Speed
    conversions.ktToft_s = @(value) conversions.NMToft(value) / 3600;
    conversions.ft_sTokt = @(value) value / conversions.ktToft_s(1);

    %% Power
    conversions.hpTolb_ft_s = @(value) value * 550;
    conversions.lb_ft_sTohp = @(value) value / conversions.hpTolb_ft_s(1);



    % Perform the conversion
    if isfield(conversions, conversionType)
        value = conversions.(conversionType)(value);
    else
        error("Conversion type not found");
    end
end
