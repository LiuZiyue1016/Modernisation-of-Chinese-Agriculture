function [result] = Met_GM11(x0, predict_num)
% �������ã�ʹ���³´�л��GM(1,1)ģ�Ͷ����ݽ���Ԥ��
%   ���룺x0��ҪԤ���ԭʼ����
%   �����predict_num�� ���Ԥ�������
%        result�� Ԥ��ֵ
    result = zeros(predict_num,1);  % ��ʼ����������Ԥ��ֵ������
    for i = 1 : predict_num  
        result(i) = GM11(x0, 1);  % ��Ԥ��һ�ڵĽ�����浽result��
        x0 = [x0(2:end); result(i)];  % ����x0��������ʱx0�����µ�Ԥ����Ϣ������ɾ�����ʼ���Ǹ�����
    end
end
