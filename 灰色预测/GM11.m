function [result, x0_hat, relative_residuals, eta] = GM11(x0, predict_num)
    % �������ã�ʹ�ô�ͳ��GM(1,1)ģ�Ͷ����ݽ���Ԥ��
    %     ���룺x�� ҪԤ���ԭʼ����
    %          predict_num�� ���Ԥ�������
    %     �����result�� Ԥ��ֵ
    %          x0_hat�� ��ԭʼ���ݵ����ֵ
    %          relative_residuals�� ��ģ�ͽ�������ʱ����õ�����Բв�
    %          eta�� ��ģ�ͽ�������ʱ����õ��ļ���ƫ��

    len = lelength(x0); % ���ݵĳ���
    x1=cumsum(x0); % ����һ���ۼ�ֵ
    z1 = (x1(1:end-1) + x1(2:end)) / 2;  % ������ھ�ֵ�������У�����Ϊlen-1��
    % ���ӵڶ��ʼ��x0����y��z1����x��������һԪ�ع�  y = kx +b
    y = x0(2:end); x = z1;
    k = ((len-1)*sum(x.*y)-sum(x)*sum(y))/((len-1)*sum(x.*x)-sum(x)*sum(x));
    b = (sum(x.*x)*sum(y)-sum(x)*sum(x.*y))/((len-1)*sum(x.*x)-sum(x)*sum(x));
    a = -k;  %ע�⣺k = -aŶ
    % -a�Ƿ�չϵ��,  b�ǻ�������
    
    disp('���ڽ���GM(1,1)Ԥ���ԭʼ������: ')
    disp(mat2str(x0'))  % mat2str���Խ������������ת��Ϊ�ַ�����ʾ
    disp(strcat('��С���˷���ϵõ��ķ�չϵ��Ϊ',num2str(-a),'������������',num2str(b)))
    disp('***************�ָ���***************')
    x0_hat=zeros(len,1);  x0_hat(1)=x0(1);   % x0_hat���������洢��x0���е����ֵ�������Ƚ��г�ʼ��
    for m = 1: len-1
        x0_hat(m+1) = (1-exp(a))*(x0(1)-b/a)*exp(-a*m);
    end
    result = zeros(predict_num,1);  % ��ʼ����������Ԥ��ֵ������
    for i = 1: predict_num
        result(i) = (1-exp(a))*(x0(1)-b/a)*exp(-a*(len+i-1)); % ���빫ʽֱ�Ӽ���
    end

    % ������Բв����Բв�
    absolute_residuals = x0(2:end) - x0_hat(2:end);   % �ӵڶ��ʼ������Բв��Ϊ��һ������ͬ��
    relative_residuals = abs(absolute_residuals) ./ x0(2:end);  % ������Բвע�����Ҫ�Ӿ���ֵ������Ҫʹ�õ��
    % ���㼶�Ⱥͼ���ƫ��
    class_ratio = x0(2:end) ./ x0(1:end-1) ;  % ���㼶�� sigma(k) = x0(k)/x0(k-1)
    eta = abs(1-(1-0.5*a)/(1+0.5*a)*(1./class_ratio));  % ���㼶��ƫ��
end
