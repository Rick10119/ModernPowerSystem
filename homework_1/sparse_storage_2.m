%% ����洢
% Ĭ�Ͻ��������� A �洢ΪU, JU, IU
U = [];% U���д洢
JU = [];
IU = [1];
for idx = 1 : n
    
    d_JU = find(Y(idx, idx + 1:n) ~= 0); % �ҵ����еķ�����
    
    if ~isempty(d_JU)
        d_JU = d_JU + idx * ones(1, size(d_JU, 2));
        U = [U, Y(idx, d_JU)];
        JU = [JU, d_JU];
        IU = [IU, IU(idx) + size(d_JU, 2)];
    else
        IU = [IU, IU(idx)];
    end
end

D = diag(Y);
JL = IU;% L���д洢
IL = JU;
L = U;

%% ϡ���ʽLU�ֽ�
% A = zeros(n, n);
% L2 = zeros(n, n);
% U2 = zeros(n, n);
% for p = 1 : n-1
%     for k = IU(p) : IU(p+1)-1
%         U(k) = U(k) / D(p);
%         j = JU(k);
%         for l = JL(p) : JL(p+1)-1
%             i = IL(l);
%             A(i, j) = A(i, j) - U(k) * L(l);
%             if  i>= j
%                 L2()A(i, j) = A(i, j) - U(k) * L(l);
%         end
%     end
% end