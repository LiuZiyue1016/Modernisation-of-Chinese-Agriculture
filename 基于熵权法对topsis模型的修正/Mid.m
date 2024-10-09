function [result] = Mid(x,best)
    M = max(abs(x-best));
    result = 1 - abs(x-best) / M;
end
