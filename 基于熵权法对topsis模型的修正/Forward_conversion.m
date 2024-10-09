
function [result] = Forward_conversion(x,N,i)
% 输入三个变量：
% x：需要正向化处理的指标对应的原始列向量
% N： 指标类型（1：极小型， 2：中间型， 3：区间型）
% i: 正在处理的是原始矩阵中的哪一列
% 输出变量result表示：正向化后的列向量
    if N == 1  %极小型
        disp(['第' num2str(i) '列是极小型，正在正向化'] )
        result = Min(x);  %调用Min函数来正向化
        disp(['第' num2str(i) '列极小型正向化处理完成'] )
        disp('~~~~~~~~~~~~~~~~~~~~分界线~~~~~~~~~~~~~~~~~~~~')
    elseif N == 2  %中间型
        disp(['第' num2str(i) '列是中间型'] )
        best = input('请输入最佳的那一个值： ');
        result = Mid(x,best);  %调用Mid函数来正向化
        disp(['第' num2str(i) '列中间型正向化处理完成'] )
        disp('~~~~~~~~~~~~~~~~~~~~分界线~~~~~~~~~~~~~~~~~~~~')
    elseif N == 3  %区间型
        disp(['第' num2str(i) '列是区间型'] )
        a = input('请输入区间的下界： ');
        b = input('请输入区间的上界： '); 
        result = Inter(x,a,b);  %调用Inter函数来正向化
        disp(['第' num2str(i) '列区间型正向化处理完成'] )
        disp('~~~~~~~~~~~~~~~~~~~~分界线~~~~~~~~~~~~~~~~~~~~')
    else
        disp('没有这种类型的指标，请检查N向量中是否有除了1、2、3之外的其他值')
    end
end
