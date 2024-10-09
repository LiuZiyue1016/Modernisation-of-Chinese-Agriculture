function [W] = find_weight(Z)
% 计算有n个样本，m个指标的样本所对应的的熵权
% 输入Z ： n*m的矩阵（经过正向化和标准化处理，且元素中不存在负数）
% 输出W：权重，1*m的行向量

%% 计算熵权
    [n,m] = size(Z);
    D = zeros(1,m);  % 初始化保存信息效用值的行向量
    for i = 1:m
        x = Z(:,i);  % 取出第i列的指标
        p = x / sum(x);
        % 注意，p有可能为0，此时计算ln(p)*p时，Matlab会返回NaN，为了防止权重为0，这里我们自己定义一个函数defense
        e = -sum(p .* defense(p)) / log(n); % 计算信息熵
        D(i) = 1- e; % 计算信息效用值
    end
    W = D ./ sum(D);  % 将信息效用值归一化，得到权重    
end
