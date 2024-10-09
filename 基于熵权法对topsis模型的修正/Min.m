function [result] = Min(x)
    result = max(x) - x;
    % result = 1 / x; 如果x全部都大于0，也可以这样正向化
end
