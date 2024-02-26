function [xdata] = iterpol(mat, wt, flag)


% Flag = 0 need a weight
% Flag = 1 have a value to interpolate to

if flag == 0
    for i = 1:length(mat)

        y1 = mat(i,2);
        y0 = mat(i,1);

        xdata(i) = wt * y1 + (1-wt) * y0;

    end

elseif flag == 1
    c=2;
    while mat(c,1) < wt
        c = c+1;
    end

    y1 = mat(c,2);
    y0 = mat(c-1,2);
    x1 = mat(c,1);
    x0 = mat(c-1,1);

    xdata = (((y1-y0)/(x1-x0))*(wt-x0)) + y0;
end


