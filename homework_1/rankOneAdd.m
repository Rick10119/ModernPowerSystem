% ���� branch��Ϣ����1����

M = zeros(n, 1);% ���֧·
M(from) = 1;
M(to) = -1;
N = M;
a = y_l;
[L, D, U] = rankOne(L, D, U, M, N, a);

M = zeros(n, 1);% ���֧·����
M(from) = 1;
N = M;
a = y_b;
[L, D, U] = rankOne(L, D, U, M, N, a);

M = zeros(n, 1);% ���֧·����
M(to) = 1;
N = M;
a = y_b;
[L, D, U] = rankOne(L, D, U, M, N, a);