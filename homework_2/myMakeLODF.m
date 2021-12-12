function LODF = myMakeLODF(mpc)
% ��֧·-֧· ���Ϸֲ����Ӿ��� D
%   LODF = MAKELODF(BRANCH, PTDF) returns the DC line outage
%   distribution factor matrix. The matrix is nbr x nbr,
%   where nbr is the number of branches.
%

[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

branch = mpc.branch;% ֧·����
bus = mpc.bus; % �ڵ����
nl = size(branch, 1); % ֧·����
nb = size(bus, 1); % �ڵ�����

[B0, ~, ~, ~] = makeBdc(mpc);% 1/x���ɵ��迹����

ref = find(bus(:, 2) == 3);% �ο��ڵ�
B0 = [B0(1 : ref - 1, 1 : ref - 1), B0(1 : ref - 1, ref + 1 : end); ...
    B0(ref + 1 : end, 1 : ref - 1), B0(ref + 1 : end, ref + 1 : end)];% ��ȥ�ο��ڵ��Ӧ��λ��
X = inv(B0);% ����

D = zeros(nl, nl);% ��ʼ������

for l = 1 : nl
        M_l = zeros(nb, 1);% l �Ĺ�������
        M_l(branch(l, F_BUS)) = 1;
        M_l(branch(l, T_BUS)) = -1;
        if ref == 1% ��ȥ�ο��ڵ��Ӧ��λ��
            M_l = M_l(ref+1:end);
        else 
            M_l = [M_l(1:ref-1); M_l(ref+1:end)];
        end
        eta_l = X * M_l;
        X_l_l = M_l' * eta_l;% ���迹
        x_l = branch(l, BR_X);% ��·�翹
        c_l = inv( - x_l + X_l_l);
 
    for k = 1 : nl
        M_k = zeros(nb, 1);% k �Ĺ�������
        M_k(branch(k, F_BUS)) = 1;
        M_k(branch(k, T_BUS)) = -1;
        if ref == 1% ��ȥ�ο��ڵ��Ӧ��λ��
            M_k = M_k(ref+1:end);
        else 
            M_k = [M_k(1:ref-1); M_k(ref+1:end)];
        end
        x_k = branch(k, BR_X);% ��·�翹
        
%         D(k, l) = 1/x_k * M_k' * (X - eta_l * c_l * eta_l.') * M_l;
        D(k, l) = M_k' * eta_l/x_k/(1 - X_l_l/x_l);
        if k == l % ��ϵ��Ϊ -1
            D(k, l)  = -1;
        end
        if branch(k, 11) ~= 1% �Ѿ����ϵ�֧·ȡ 0
                D(k, l)  = 0;
        end
                
    end
end

LODF = D;

