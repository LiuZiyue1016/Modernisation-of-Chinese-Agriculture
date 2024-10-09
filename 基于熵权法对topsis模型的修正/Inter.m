function [result] = Inter(x,a,b)
    r_x = size(x,1);  % row of x 
    M = max([a-min(x),max(x)-b]);
    result = zeros(r_x,1); 
    % 初始化result全为0
    for i = 1: r_x
        if x(i) < a
           result(i) = 1-(a-x(i))/M;
        elseif x(i) > b
           result(i) = 1-(x(i)-b)/M;
        else
           result(i) = 1;
        end
    end
end
