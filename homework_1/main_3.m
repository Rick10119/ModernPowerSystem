%% 3.1 在节点 5 与节点 8 之间添加支路
% 生成Y矩阵
Y = makeYbus(case14);
Y1 = Y; Y2 = Y;
n = length(Y);

branch58;% 读取数据
%% 面向支路
% 添加线路导纳 b/2 -> (5 ,8)
% 构造关联矩阵 (from, n+1)
M = zeros(n, 1);
M(from) = 1;
% 添加支路
Y1 = Y1 + M * y_b * M';

% % 构造关联矩阵 (to, n+1)
M = zeros(n, 1);
M(to) = 1;
% 添加支路
Y1 = Y1 + M * y_b * M';

% 添加线路 y
M = zeros(n, 1);
M(from) = 1;
M(to) = -1;
Y1 = Y1 + M * y_l * M';

%% 面向节点
branch58;% 读取数据
y = [y_l + y_b, - y_l; ...
    - y_l, y_l + y_b];

M = zeros(n, 2);
M(from, 1) = 1;
M(to, 2) = 1;

Y2 = Y2 + M * y * M';

norm(Y1 - Y2, 1);

%% 3.2 再在节点 11 与节点 12 之间添加支路（用于验证）
branch1112;% 读取数据

% 面向节点添加
y = [y_l + y_b, - y_l; ...
    - y_l, y_l + y_b];

M = zeros(n, 2);
M(from, 1) = 1;
M(to, 2) = 1;

Y2 = Y2 + M * y * M';

%% 秩 1 修正
% 利用自己写的rankOne()函数
[L, D, U] = factorize(Y);

branch58;% 读取数据
rankOneAdd;% 修正

branch1112;% 读取数据
rankOneAdd;% 修正

disp("秩 1 修正误差： " + norm(L * D * U - Y2, 1));


%% 局部再分解
%
[L, D, U] = factorize(Y);
% 从 5 开始为 A22
index = 5;
delta_A22 = Y2(5:end, 5:end) - Y(5:end, 5:end);
A22_prime = L(5:end, 5:end) * D(5:end, 5:end) * U(5:end, 5:end);
A22_prime_tidle = A22_prime + delta_A22;
% 局部再分解
[L22, D22, U22] = factorize(A22_prime_tidle);
% 修正因子表
L(5:end, 5:end) = L22;
D(5:end, 5:end) = D22;
U(5:end, 5:end) = U22;

disp("局部再分解误差： " + norm(L * D * U - Y2, 1));

%% 3.3 根据新因子表，计算添加后的节点导纳矩阵 Y’’和节点阻抗矩阵 Z’’
Y_new = L * D * U;

% 利用自己写的函数 ldu2Z() 生成Z
Z_new = ldu2Z(L, D, U);

% 利用 Y1 生成 Z
Z = inv(Y1);% 原来的阻抗矩阵
branch1112;% 读取数据
% 添加支路
M = zeros(n, 1);% 关联向量
M(from) = 1;
M(to) = -1;
c = inv(1/y_l + M' * Z * M);
Z = Z - Z * M * c* M' * Z;

% 添加线路导纳 
% 添加 (from, n+1)
M = zeros(n, 1);% 构造关联矩阵 (from, n+1)
M(from) = 1;
c = inv(1/y_b + M' * Z * M);
Z = Z - Z * M * c * M' * Z;% 添加并联支路
% 添加 (to, n+1)
M = zeros(n, 1);% 构造关联矩阵 (to, n+1)
M(to) = 1;
c = inv(1/y_b + M' * Z * M);
Z = Z - Z * M * c * M' * Z;% 添加并联支路

disp("矩阵求逆定理误差： " + norm(Z - Z_new, 1));
