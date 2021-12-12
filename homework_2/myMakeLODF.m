function LODF = myMakeLODF(mpc)
% 求支路-支路 开断分布因子矩阵 D
%   LODF = MAKELODF(BRANCH, PTDF) returns the DC line outage
%   distribution factor matrix. The matrix is nbr x nbr,
%   where nbr is the number of branches.
%

[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

branch = mpc.branch;% 支路矩阵
bus = mpc.bus; % 节点矩阵
nl = size(branch, 1); % 支路数量
nb = size(bus, 1); % 节点数量

[B0, ~, ~, ~] = makeBdc(mpc);% 1/x生成的阻抗矩阵

ref = find(bus(:, 2) == 3);% 参考节点
B0 = [B0(1 : ref - 1, 1 : ref - 1), B0(1 : ref - 1, ref + 1 : end); ...
    B0(ref + 1 : end, 1 : ref - 1), B0(ref + 1 : end, ref + 1 : end)];% 划去参考节点对应的位置
X = inv(B0);% 求逆

D = zeros(nl, nl);% 初始化矩阵

for l = 1 : nl
        M_l = zeros(nb, 1);% l 的关联矩阵
        M_l(branch(l, F_BUS)) = 1;
        M_l(branch(l, T_BUS)) = -1;
        if ref == 1% 划去参考节点对应的位置
            M_l = M_l(ref+1:end);
        else 
            M_l = [M_l(1:ref-1); M_l(ref+1:end)];
        end
        eta_l = X * M_l;
        X_l_l = M_l' * eta_l;% 互阻抗
        x_l = branch(l, BR_X);% 线路电抗
        c_l = inv( - x_l + X_l_l);
 
    for k = 1 : nl
        M_k = zeros(nb, 1);% k 的关联矩阵
        M_k(branch(k, F_BUS)) = 1;
        M_k(branch(k, T_BUS)) = -1;
        if ref == 1% 划去参考节点对应的位置
            M_k = M_k(ref+1:end);
        else 
            M_k = [M_k(1:ref-1); M_k(ref+1:end)];
        end
        x_k = branch(k, BR_X);% 线路电抗
        
%         D(k, l) = 1/x_k * M_k' * (X - eta_l * c_l * eta_l.') * M_l;
        D(k, l) = M_k' * eta_l/x_k/(1 - X_l_l/x_l);
        if k == l % 自系数为 -1
            D(k, l)  = -1;
        end
        if branch(k, 11) ~= 1% 已经开断的支路取 0
                D(k, l)  = 0;
        end
                
    end
end

LODF = D;

