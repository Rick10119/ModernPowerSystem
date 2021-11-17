%% LDU因子表的秩1修正
function [L_new, D_new, U_new] = rankOne(L, D, U, M, N, a)
%
% INPUT DATA:
%   原来的L, D, U矩阵
%   关联矩阵M, N
%   修正量 a

% OUTPUT DATA:
%   新的L, D, U矩阵
%

% 终止条件
if length(D) == 1
    L_new = L;
    D_new = D + M * a * N;
    U_new = U;
    return
end

% 本层：
D(1, 1) = D(1, 1) + M(1) * a * N(1);

N(2 : end) = N(2 : end) - (N(1) * U(1, 2 : end)).';
U(1, 2:end) = U(1, 2:end) + inv(D(1, 1)) * M(1) * a * N(2 : end).';

M(2 : end) = M(2 : end) - L(2 : end, 1) * M(1);
L(2 : end, 1) = L(2 : end, 1) + M(2 : end) * a * N(1) * inv(D(1, 1));

a = a - a * N(1) * inv(D(1, 1)) * M(1) * a;

% 递归
[L(2:end, 2:end), D(2:end, 2:end), U(2:end, 2:end)] = rankOne( ...
    L(2:end, 2:end), D(2:end, 2:end), U(2:end, 2:end), M(2:end), N(2:end), a);

L_new = L;
D_new = D;
U_new = U;

end
