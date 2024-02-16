function TOP = TOP_function(Stog)
    % Coefficients of the quadratic equation
    a = 0.0149;
    b = 8.134;
    c = -Stog;

    % Solve the quadratic equation
    discriminant = b^2 - 4*a*c;

    if discriminant < 0
        % No real solutions
        TOP_values = [];
    else
        % Calculate the two solutions
        x1 = (-b + sqrt(discriminant)) / (2*a);
        x2 = (-b - sqrt(discriminant)) / (2*a);
        
        % Return the solutions
        TOP_values = [x1, x2];
        TOP = x1;
    end
end