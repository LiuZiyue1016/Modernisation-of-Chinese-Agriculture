clear;clc
% 定义源文件夹路径
parentFolder = 'C:\Users\Lzy\Desktop\数据\未归一化\熵权法'; % 修改为你的父文件夹路径

folderNames = {'Beijing', 'Tianjin', 'Hebei', 'Shanxi', 'Neimenggu', 'Liaonin', 'Jilin', 'Heilongjiang', 'Shanghai', 'Jiangsu', 'Zhejiang'...
    'Anhui', 'Fujian', 'Jiangxi', 'Shandong', 'Henan', 'Hubei', 'Hunan', 'Guangdong', 'Guangxi', 'Hainan', 'Chongqin', 'Sichuan', 'Guizhou' ...
    'Yunnan', 'Shanxi', 'Gansu', 'Qinghai', 'Ningxia', 'Xinjiang'}; % 修改为你的30个文件夹名称

for o = 1:numel(folderNames)
    folderPath = fullfile(parentFolder, folderNames{o});
    if ~exist(folderPath, 'dir')
        mkdir(folderPath);
    end

    for i = 1:5
        %%  第一步：读取数据
        % 构造文件名和源文件路径
        file = fullfile(folderPath, num2str(i));
        if ~exist(file, 'dir')
            mkdir(file);
        end
        
        % 指定 Excel 文件名和要读取的工作表
        filename = '数据.xlsx';
        sheet = 1;
                
        % 计算当前数据列的行数范围
        row_start = 4 + 15*(o-1);
        row_end = 13 + 15*(o-1);
        line_start = ['C', 'J', 'N', 'T', 'X']
        line_end = ['G', 'K', 'Q', 'U', 'Z']
        
        range = sprintf('%c%d:%c%d', line_start(i),  row_start, line_end(i), row_end);
        
        % 读取当前数据列的数据并存储为列向量
        data = xlsread(filename, sheet, range);
        
        % 将读取的数据存储为列向量 x0
        X = data();

        %%  第二步：判断是否需要正向化
        [n,m] = size(X);
        disp(['共有' num2str(n) '个评价对象, ' num2str(m) '个评价指标']) 

        % 第三一级指标和第四一级指标下的第二列数据需要正向化，且均为极小型
        if i==3||i==4
            M = [2]
            N = [1]
            % M和N均为两个同维度的行向量
            for m = 1 : size(M,2)  %计算循环次数
                X(:,M(m)) = Forward_conversion(X(:,M(m)),N(m),M(m));
            % 用Forward_conversion函数进行正向化，接收三个参数
            % 第一个参数：进行正向化处理的那一列向量 X(:,M(i))
            % 第二个参数：这一列的指标类型（1：极小型， 2：中间型， 3：区间型）
            % 第三个参数：告诉函数我们正在处理的是原始矩阵中的哪一列
            % 该函数返回正向化之后的指标，将其直接赋值给我们原始要处理的那一列向量
            end
            disp('正向化后的矩阵 X =  ')
            disp(X)
        end
        
        %% 第三步：将正向化后的矩阵进行标准化
        Z = X ./ repmat(sum(X.*X) .^ 0.5, n, 1);
        disp('标准化矩阵 Z = ')
        disp(Z)
        
        %% 判断是否需要增加权重
        if sum(sum(Z<0)) >0   % 如果之前标准化后的Z矩阵中存在负数，则重新对X进行标准化
            disp('原来标准化得到的Z矩阵中存在负数，所以需要对X重新标准化')
            for s = 1:n
                for j = 1:m
                    Z(s,j) = [X(s,j) - min(X(:,j))] / [max(X(:,j)) - min(X(:,j))];
                end
            end
            disp('X重新进行标准化得到的标准化矩阵Z为:  ')
            disp(Z)
        end

        weight = find_weight(Z);
        
        disp('熵权法确定的权重为：')
        disp(weight)

        %% 第四步：计算与最大值的距离和最小值的距离，并算出得分
        D_P = sum([(Z - repmat(max(Z),n,1)) .^ 2 ] .* repmat(weight,n,1) ,2) .^ 0.5;   % D+ 与最大值的距离向量
        D_N = sum([(Z - repmat(min(Z),n,1)) .^ 2 ] .* repmat(weight,n,1) ,2) .^ 0.5;   % D- 与最小值的距离向量
        S = D_N ./ (D_P+D_N);    % 未归一化的得分
        disp('最后的得分为：')
        stand_S = S / sum(S)  % 归一化的得分
        %% 第五步：将数据保存
        filename_1 = '权重.xlsx';
        filename_2 = '未归一化得分.xlsx';
        filename_3 = '归一化得分.xlsx';
        
        writematrix(weight, fullfile(file, filename_1));
        writematrix(S, fullfile(file, filename_2));
        writematrix(stand_S, fullfile(file, filename_3));
        disp("已保存成功")
    end  
end
    
    