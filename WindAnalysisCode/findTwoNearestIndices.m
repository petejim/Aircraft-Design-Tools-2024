%% AERO 444 - Senior Design 2 - Route Wind Analysis Tool

function indexes = findTwoNearestIndices(array, desired_value)

    if length(array) == 144 && desired_value > 357.5
        array(end+1) = 360;
    end

    indexes = [1, length(array)]; 

    % Sort the array and keep track of the original indices
    [sortedArray, originalIndices] = sort(array);
    
    % Find the index where the sorted array is just greater than or equal to the desired value
    greaterIndex = find(sortedArray >= desired_value, 1, 'first');
    
    % Check if the greaterIndex is the first element
    if greaterIndex == 1
        indexes = [originalIndices(1), originalIndices(2)];
    else
        % If greaterIndex is not the first, take one index before it for the lesser index
        indexes = [originalIndices(greaterIndex - 1), originalIndices(greaterIndex)];
    end

    % Extract the indices of the two nearest values
    first_index = indexes(1);
    second_index = indexes(2);

    diff = double(array(second_index) - array(first_index));
    diff2 = double(desired_value - double(array(first_index)));
    alpha1 = 1 - double(diff2./diff);
    if diff2 == 0 
        alpha2 = 0;
    else
        alpha2 = double(diff2./diff);
    end

    if length(array) == 145 && desired_value > 357.5
       second_index = 1;
    end

    indexes = [first_index, second_index, alpha1, alpha2];

end