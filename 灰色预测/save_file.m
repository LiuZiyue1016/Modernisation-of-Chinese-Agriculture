clear;clc
% 定义源文件夹路径
parentFolder = 'C:\Users\Lzy\Desktop\灰色预测\代码和例题数据\灰色预测\数据'; % 修改为你的父文件夹路径

folderNames = {'Beijing', 'Tianjin', 'Hebei', 'Shanxi', 'Neimenggu', 'Liaonin', ' Jilin', ' Heilongjiang', 'Shanghai', ' Jiangsu', 'Zhejiang'...
    'Anhui', 'Fujian', ' Jiangxi', 'Shandong', 'Henan', 'Hubei', 'Hunan', 'Guangdong', 'Guangxi', 'Hainan', 'Chongqin', 'Sichuan', 'Guizhou' ...
    'Yunnan', 'Shanxi', 'Gansu', 'Qinghai', 'Ningxia', 'Xinjiang'}; % 修改为你的30个文件夹名称
for o = 1:numel(folderNames)
    folderPath = fullfile(parentFolder, folderNames{o});
    
    if ~exist(folderPath, 'dir')
        mkdir(folderPath);
    end

%     for i = 1:5
%         % 构造文件名和源文件路径
%         file = fullfile(folderPath, num2str(i));       
%         if ~exist(file, 'dir')
%             mkdir(file);
%         end
%     end
end