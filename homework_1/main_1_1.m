%% 基于 IEEE 14 节点系统生成节点不定导纳矩阵 Y0
mpc = case14; % 读取14节点数据

% 母线和支路数量
n = length(mpc.bus);
m = length(mpc.branch);

% 初始化
Y0 = zeros(n+1, n+1);

for idx  = 1 : m % 逐个branch 添加
    
    % 添加线路导纳 b/2 -> (from, n+1), (to, n+1)
    y_l = 1/2 * mpc.branch(idx, 5) * 1j; % b/2
    % 构造关联矩阵 (from, n+1)
    M_a = zeros(n + 1, 1);
    M_a(mpc.branch(idx, 1)) = 1;
    M_a(n + 1) = -1;
    % 添加支路
    Y0 = Y0 + M_a * y_l * M_a';
    
    % 构造关联矩阵 (to, n+1)
    M_a = zeros(n + 1, 1);
    M_a(mpc.branch(idx, 2)) = 1;
    M_a(n + 1) = -1;
    % 添加支路
    Y0 = Y0 + M_a * y_l * M_a';
    
    % 添加支路电导
     y_b = 1/ (mpc.branch(idx, 3:4) * [1, 1j].' );% 电导，branch的1/(r + ix)
    % 构造关联矩阵 (from, to)
    M_a = zeros(n + 1, 1);
    M_a(mpc.branch(idx, 1)) = 1; % 节点编号在branch 的 from(1), to(2)
    M_a(mpc.branch(idx, 2)) = -1;
    % 变压器(不考虑移相器)
    t = mpc.branch(idx, 9);
    if t ~= 0
        M_a(mpc.branch(idx, 1)) = 1 / t;
    end
    % 添加支路
    Y0 = Y0 + M_a * y_b * M_a';
end


% 加上母线的接地支路
for idx  = 1 : n
    
    % 接地导纳
    y_shunt = mpc.bus(idx, 5:6) * [1, 1j].' / mpc.baseMVA;
    
    % 关联矩阵
    M_a = zeros(n + 1, 1);
    M_a(idx) = 1;
    M_a(length(mpc.bus) + 1) = -1;
    
    
    
    % 添加支路
    Y0 = Y0 + M_a * y_shunt * M_a';
    
end


%% 1.1 以地为参考节点生成节点导纳矩阵 Y

Y = Y0(1: n, 1:n);

%% 1.2 使用makeYbus()
Y_makeYbus = makeYbus(mpc);

% 验证
disp("Y 与makeYbus差别： " + norm(Y - Y_makeYbus, 1));
