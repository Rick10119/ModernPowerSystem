%% 2.1 节点导纳矩阵 Y 进行 LDU 分解
% 生成Y矩阵
Y = makeYbus(case14);

%% LU分解
A = Y;
n = size(A, 1);

%对比自带的lu分解
[L1, U1] = lu(A);
D1 = diag(diag(U1));
U1 = D1 \ U1;
norm(L1 * D1 * U1 - Y, 1);

% 自己写的因子分解（函数 factorize(））
[L2, D2, U2] = factorize(A);
norm(L2 * D2 * U2 - Y, 1);

%% 2.2 采用 Tinney-2 编号方法、Tinney-3 编号, 对比LDU分解
% 自己写的 TinneyTwo(), TinneyThree() 函数
mpc = case14;% 读取数据为mpc

test_times = 1;% 执行次数

%% 测试编号所需时间
tic
for i = 1 : test_times
    [bus_new2, branch_new2] = TinneyTwo(mpc.baseMVA, mpc.bus, mpc.branch);
end
t_order_2 = toc;

tic
for i = 1 : test_times
    [bus_new3, branch_new3] = TinneyThree(mpc.baseMVA, mpc.bus, mpc.branch);
end
t_order_3 = toc;

%% 测试LDU分解所需时间
tic
for i = 1 : test_times
    [L1, D1, U1] = factorize(makeYbus(case14));% 原始编号
end
t_factorize_1 = toc;

tic
for i = 1 : test_times
    [L2, D2, U2] = factorize(makeYbus(mpc.baseMVA, bus_new2, branch_new2));% Tinney-2编号
end
t_factorize_2 = toc;

tic
for i = 1 : test_times
    [L3, D3, U3] = factorize(makeYbus(mpc.baseMVA, bus_new3, branch_new3));% Tinney-3编号
end
t_factorize_3 = toc;

%% 统计非零元个数
nofNZ1 = length(find(L1 ~= 0));
nofNZ2 = length(find(L2 ~= 0));
nofNZ3 = length(find(L3 ~= 0));

%% 2.3 基于 LDU 分解的结果，采用连续回代法重新生成节点阻抗矩阵 Z
[L, D, U] = factorize(makeYbus(case14));
 
% 利用自己写的函数 ldu2Z() 生成Z
Z = ldu2Z(L, D, U);

disp("LDU生成Z误差： " + norm(inv(Y) - Z, 1));

