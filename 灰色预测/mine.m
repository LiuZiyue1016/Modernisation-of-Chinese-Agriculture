%%  输入原始数据并做出时间序列图
clear;clc
year =[2012:1:2021]';  % 横坐标表示年份，写成列向量的形式（加'就表示转置）

% 指定 Excel 文件名和要读取的工作表
filename = '总数据_未归一化.xlsx';
sheet = 1;

path = 'C:\Users\Lzy\Desktop\代码\灰色预测'
parentFolder = 'C:\Users\Lzy\Desktop\数据\未归一化\灰色预测'; % 修改为你的父文件夹路径
% 循环读取每列数据
folderNames = {'Beijing', 'Tianjin', 'Hebei', 'Shanxi', 'Neimenggu', 'Liaonin', 'Jilin', 'Heilongjiang', 'Shanghai', 'Jiangsu', 'Zhejiang'...
    'Anhui', 'Fujian', 'Jiangxi', 'Shandong', 'Henan', 'Hubei', 'Hunan', 'Guangdong', 'Guangxi', 'Hainan', 'Chongqin', 'Sichuan', 'Guizhou' ...
    'Yunnan', 'Shanxi', 'Gansu', 'Qinghai', 'Ningxia', 'Xinjiang'}; % 修改为你的30个文件夹名称

for i = 1:30
    j = i
    folderPath = fullfile(parentFolder, folderNames{i});
    % 计算当前数据列的行数范围
    row_start = 4 + 15*(i-1);
    row_end = 14 + 15*(i-1);
    range = sprintf('AD%d:AD%d', row_start, row_end);
    
    
    % 读取当前数据列的数据并存储为列向量
    data = xlsread(filename, sheet, range);
    
    % 将读取的数据存储为列向量 x0
    x0 = data(:);
    
    % 画出原始数据的时间序列图
    fig1 = figure(1); % 设置编号
    plot(year,x0,'o-'); grid on;  % 原式数据的时间序列图
    set(gca,'xtick',year(1:1:end))  % 设置x轴横坐标的间隔为1
    xlabel('年份');  ylabel('得分');  % 加标签
    % 保存图片
    cd(folderPath);
    saveas(fig1, 'fig1.png');
    cd(path);
    clf
    
    %% 使用GM(1,1)模型，适用于数据期数较短的非负时间序列
    ERROR = 0;  % 建立一个错误指标，一旦出错就指定为1
    % 判断是否有负数元素
    if sum(x0<0) > 0  % x0<0返回一个逻辑数组(0-1组成)，如果有数据小于0，则所在位置为1，如果原始数据均为非负数，那么这个逻辑数组中全为0，求和后也是0~
        disp('灰色预测的时间序列中不能有负数')
        ERROR = 1;
    end
    
    % 判断数据量是否太少
    n = length(x0);  % 计算原始数据的长度
    disp(strcat('原始数据的长度为',num2str(n)))   
    if n<=3
        disp('数据量太小，无能为力')
        ERROR = 1;
    end
    
    % 数据太多时提示可考虑使用其他方法
    if n>10
        disp('数据量太多，请考虑使用其他的方法')
    end
    
    % 判断数据是否为列向量，如果输入的是行向量则转置为列向量
    if size(x0,1) == 1
        x0 = x0';
    end
    if size(year,1) == 1
        year = year';
    end
    
    
    %% 对一次累加后的数据进行准指数规律的检验(注意，这个检验有时候即使能通过，也不一定能保证预测结果非常好)
    if ERROR == 0   % 如果上述错误均没有发生时，才能执行下面的操作步骤
        disp('------------------------------------------------------------')
        disp('准指数规律检验')
        x1 = cumsum(x0);   % 生成1-AGO序列，cumsum是累加函数
        rho = x0(2:end) ./ x1(1:end-1) ;   % 计算光滑度rho(k) = x0(k)/x1(k-1)
        
        % 画出光滑度的图形，并画上0.5的直线，表示临界值
        fig2 = figure(2)
        plot(year(2:end),rho,'o-',[year(2),year(end)],[0.5,0.5],'-'); grid on;
        text(year(end-1)+0.2,0.55,'临界线')   % 在坐标(year(end-1)+0.2,0.55)上添加文本
        set(gca,'xtick',year(2:1:end))  % 设置x轴横坐标的间隔为1
        xlabel('年份');  ylabel('原始数据的光滑度');  % 加标签
        % 保存图片
        cd(folderPath);
        saveas(fig2, 'fig2.png');
        cd(path);
        clf

        disp(strcat('指标1：光滑比小于0.5的数据占比为',num2str(100*sum(rho<0.5)/(n-1)),'%'))
        disp(strcat('指标2：除去前两个时期外，光滑比小于0.5的数据占比为',num2str(100*sum(rho(3:end)<0.5)/(n-3)),'%'))
        disp('参考标准：指标1一般要大于60%, 指标2要大于90%')
        
        disp('------------------------------------------------------------')
    end
    
    %% 当数据量大于4时，我们利用试验组来选择使用传统的GM(1,1)模型、新信息GM(1,1)模型还是新陈代谢GM(1,1)模型； 如果数据量等于4，那么我们直接对三种方法求一个平均来进行预测
    if ERROR == 0   % 如果上述错误均没有发生时，才能执行下面的操作步骤
        if  n > 4  % 数据量大于4时，将数据分为训练组和试验组(根据原数据量大小n来取，n为5-7个则取最后两年为试验组，n大于7则取最后三年为试验组)
            disp('因为原数据的期数大于4，所以我们可以将数据组分为训练组和试验组')   % 注意：如果试验组的个数只有1个，那么三种模型的结果完全相同，因此至少要取2个试验组
            if n > 7
                test_num = 3;
            else
                test_num = 2;
            end
            train_x0 = x0(1:end-test_num);  % 训练数据
            disp('训练数据是: ')
            disp(mat2str(train_x0'))  % mat2str可以将矩阵或者向量转换为字符串显示, 这里加一撇表示转置，把列向量变成行向量方便观看
            test_x0 =  x0(end-test_num+1:end); % 试验数据
            disp('试验数据是: ')
            disp(mat2str(test_x0'))  % mat2str可以将矩阵或者向量转换为字符串显示
            disp('------------------------------------------------------------')
            
            % 使用三种模型对训练数据进行训练，返回的result就是往后预测test_num期的数据
            disp(' ')
            disp('***下面是传统的GM(1,1)模型预测的详细过程***')
            result1 = GM11(train_x0, test_num); %使用传统的GM(1,1)模型对训练数据，并预测后test_num期的结果
            disp(' ')
            disp('***下面是进行新信息的GM(1,1)模型预测的详细过程***')
            result2 = new_GM11(train_x0, test_num); %使用新信息GM(1,1)模型对训练数据，并预测后test_num期的结果
            disp(' ')
            disp('***下面是进行新陈代谢的GM(1,1)模型预测的详细过程***')
            result3 = Met_GM11(train_x0, test_num); %使用新陈代谢GM(1,1)模型对训练数据，并预测后test_num期的结果
            
            % 现在比较三种模型对于试验数据的预测结果
            disp(' ')
            disp('------------------------------------------------------------')
            % 绘制对试验数据进行预测的图形（对于部分数据，可能三条直线预测的结果非常接近）
            test_year = year(end-test_num+1:end);  % 试验组对应的年份
            fig3 = figure(3)
            plot(test_year,test_x0,'o-',test_year,result1,'*-',test_year,result2,'+-',test_year,result3,'x-'); grid on;
            set(gca,'xtick',year(end-test_num+1): 1 :year(end))  % 设置x轴横坐标的间隔为1
            legend('试验组的真实数据','传统GM(1,1)预测结果','新信息GM(1,1)预测结果','新陈代谢GM(1,1)预测结果')  % 注意：如果lengend挡着了图形中的直线，那么lengend的位置可以自己手动拖动
            xlabel('年份');  ylabel('得分');  % 加标签
            % 保存图片
            cd(folderPath);
            saveas(fig3, 'fig3.png');
            cd(path);
            clf

            % 计算误差平方和SSE
            SSE1 = sum((test_x0-result1).^2);
            SSE2 = sum((test_x0-result2).^2);
            SSE3 = sum((test_x0-result3).^2);
            disp(strcat('传统GM(1,1)对于试验组预测的误差平方和为',num2str(SSE1)))
            disp(strcat('新信息GM(1,1)对于试验组预测的误差平方和为',num2str(SSE2)))
            disp(strcat('新陈代谢GM(1,1)对于试验组预测的误差平方和为',num2str(SSE3)))
            % 选择SSE最小的模型
            if SSE1<SSE2
                if SSE1<SSE3
                    choose = 1;  % SSE1最小，选择传统GM(1,1)模型
                else
                    choose = 3;  % SSE3最小，选择新陈代谢GM(1,1)模型
                end
            elseif SSE2<SSE3
                choose = 2;  % SSE2最小，选择新信息GM(1,1)模型
            else
                choose = 3;  % SSE3最小，选择新陈代谢GM(1,1)模型
            end
            Model = {'传统GM(1,1)模型','新信息GM(1,1)模型','新陈代谢GM(1,1)模型'};
            disp(strcat('因为',Model(choose),'的误差平方和最小，所以我们应该选择其进行预测'))
            disp('------------------------------------------------------------')
            
            %% 选用误差最小的那个模型进行预测
            predict_num = 10;
            % 计算使用传统GM模型的结果，用来得到另外的返回变量：x0_hat, 相对残差relative_residuals和级比偏差eta
            [result, x0_hat, relative_residuals, eta] = GM11(x0, predict_num);  % 先利用GM11函数得到对原数据拟合的详细结果
            
            % % 判断我们选择的是哪个模型，如果是2或3，则更新刚刚由模型1计算出来的预测结果
            if choose == 2
                result = new_GM11(x0, predict_num);
            end
            if choose == 3
                result = Met_GM11(x0, predict_num);
            end
            
            %% 输出使用最佳的模型预测出来的结果
            disp('------------------------------------------------------------')
            disp('对原始数据的拟合结果：')
            for i = 1:n
                disp(strcat(num2str(year(i)), ' ： ',num2str(x0_hat(i))))
            end
            disp(strcat('往后预测',num2str(predict_num),'期的得到的结果：'))
            for i = 1:predict_num
                disp(strcat(num2str(year(end)+i), ' ： ',num2str(result(i))))
            end
            
            %% 如果只有四期数据，那么我们就没必要选择何种模型进行预测，直接对三种模型预测的结果求一个平均值~
        else
            disp('因为数据只有4期，因此我们直接将三种方法的结果求平均即可~')
            % 预测未来10年数据
            predict_num = 10
            disp(' ')
            disp('***下面是传统的GM(1,1)模型预测的详细过程***')
            [result1, x0_hat, relative_residuals, eta] = GM11(x0, predict_num);
            disp(' ')
            disp('***下面是进行新信息的GM(1,1)模型预测的详细过程***')
            result2 = new_GM11(x0, predict_num);
            disp(' ')
            disp('***下面是进行新陈代谢的GM(1,1)模型预测的详细过程***')
            result3 = Met_GM11(x0, predict_num);
            result = (result1+result2+result3)/3;
            
            disp('对原始数据的拟合结果：')
            for i = 1:n
                disp(strcat(num2str(year(i)), ' ： ',num2str(x0_hat(i))))
            end
            disp(strcat('传统GM(1,1)往后预测',num2str(predict_num),'期的得到的结果：'))
            for i = 1:predict_num
                disp(strcat(num2str(year(end)+i), ' ： ',num2str(result1(i))))
            end
            disp(strcat('新信息GM(1,1)往后预测',num2str(predict_num),'期的得到的结果：'))
            for i = 1:predict_num
                disp(strcat(num2str(year(end)+i), ' ： ',num2str(result2(i))))
            end
            disp(strcat('新陈代谢GM(1,1)往后预测',num2str(predict_num),'期的得到的结果：'))
            for i = 1:predict_num
                disp(strcat(num2str(year(end)+i), ' ： ',num2str(result3(i))))
            end
            disp(strcat('三种方法求平均得到的往后预测',num2str(predict_num),'期的得到的结果：'))
            for i = 1:predict_num
                disp(strcat(num2str(year(end)+i), ' ： ',num2str(result(i))))
            end
        end
        
        %% 绘制相对残差和级比偏差的图形(注意：因为是对原始数据的拟合效果评估，所以三个模型都是一样的哦~~~)
        fig4 = figure(4)
        subplot(2,1,1)  % 绘制子图（将图分块）
        plot(year(2:end), relative_residuals,'*-'); grid on;   % 原数据中的各时期和相对残差
        legend('相对残差'); xlabel('年份');
        set(gca,'xtick',year(2:1:end))  % 设置x轴横坐标的间隔为1
        subplot(2,1,2)
        plot(year(2:end), eta,'o-'); grid on;   % 原数据中的各时期和级比偏差
        legend('级比偏差'); xlabel('年份');
        set(gca,'xtick',year(2:1:end))  % 设置x轴横坐标的间隔为1
        cd(folderPath);
        saveas(fig4, 'fig4.png');
        cd(path);
        clf

        disp(' ')
        disp('****下面将输出对原数据拟合的评价结果***')
        disp(j)
        %% 残差检验
        average_relative_residuals = mean(relative_residuals);  % 计算平均相对残差 mean函数用来均值
        disp(strcat('平均相对残差为',num2str(average_relative_residuals)))
        if average_relative_residuals<0.1
            disp('残差检验的结果表明：该模型对原数据的拟合程度非常不错')
        elseif average_relative_residuals<0.2
            disp('残差检验的结果表明：该模型对原数据的拟合程度达到一般要求')
        else
            disp('残差检验的结果表明：该模型对原数据的拟合程度不太好，建议使用其他模型预测')
        end
        
        %% 级比偏差检验
        average_eta = mean(eta);   % 计算平均级比偏差
        disp(strcat('平均级比偏差为',num2str(average_eta)))
        if average_eta<0.1
            disp('级比偏差检验的结果表明：该模型对原数据的拟合程度非常不错')
        elseif average_eta<0.2
            disp('级比偏差检验的结果表明：该模型对原数据的拟合程度达到一般要求')
        else
            disp('级比偏差检验的结果表明：该模型对原数据的拟合程度不太好，建议使用其他模型预测')
        end
        disp(' ')
        disp('------------------------------------------------------------')
        
        %% 绘制最终的预测效果图
        fig5 = figure(5)  % 下面绘图中的符号m:洋红色 b:蓝色
        plot(year,x0,'-o',  year,x0_hat,'-*m',  year(end)+1:year(end)+predict_num,result,'-*b' );   grid on;
        hold on;
        plot([year(end),year(end)+1],[x0(end),result(1)],'-*b')
        legend('原始数据','拟合数据','预测数据')  % 注意：如果lengend挡着了图形中的直线，那么lengend的位置可以自己手动拖动
        set(gca,'xtick',[year(1):1:year(end)+predict_num])  % 设置x轴横坐标的间隔为1
        xlabel('年份');  ylabel('得分');  % 加标签

        %保存图片
        cd(folderPath);
        saveas(fig5, 'fig5.png');
        cd(path);
        clf
    
        
        name = '预测.xlsx'
        writematrix(result, fullfile(folderPath, name));
    end
end