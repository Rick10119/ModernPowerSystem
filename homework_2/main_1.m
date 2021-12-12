%% 1、牛顿-拉夫逊方法求解潮流方程 （主程序）
clc;clear;
casedata = case14; % 选择case
% casedata = case39;

bus = casedata.bus;
gen = casedata.gen;
%% 构造 Y 矩阵、S 向量、节点类型向量、初始解
Ybus = makeYbus(casedata); % 节点导纳矩阵

Sbus = makeSbus(casedata.baseMVA, bus, gen); % 标幺化注入复功率

[ref, pv, pq] = bustypes(bus, gen); % 节点类型向量

V0  = bus(:, 8) .* exp(1j * pi/180 * bus(:, 9));% 初始化电压都设成bus 中给定的

%% 调用自己写的 NR 法求解潮流

[V1, success1, iterations1] = myNewtonpf(Ybus, Sbus, V0, ref, pv, pq);

%% 结果比较（调用自带的runpf中的 newtonpf）

mpopt = mpoption;
mpopt.pf.alg = 'NR'; % 方法选 NR 法

[MVAbase2, bus2, gen2, branch2, success2, et2] = ...
    runpf(casedata, mpopt);% 调用自带的runpf中的 newtonpf
V2 =  bus2(:, 8) .* exp(1j * pi/180 * bus2(:, 9)); % 构造电压向量

disp("myNewtonpf和newtonpf的差别：norm(V1 - V2, inf):  " + norm(V1 - V2, inf));


%% 修改节点类型
ref = 6; % 平衡节点从节点 1 修改为节点 6
pv(find(pv == 6)) = 1; % 节点 1 改为 PV 节点
pv = sort(pv); % 重新排序
[V31, success31, iterations31] = myNewtonpf(Ybus, Sbus, V0, ref, pv, pq);

% 调用 NR 法求解潮流

casedata.bus(1,2) = 2;
casedata.bus(6,2) = 3;
[MVAbase3, bus3, gen3, branch3, success3, et3] = ...
    runpf(casedata, mpopt);% 调用自带的runpf中的 newtonpf
V3 =  bus3(:, 8) .* exp(1j * pi/180 * bus3(:, 9));

disp("myNewtonpf和newtonpf的差别：norm(V31 - V3, inf)： " + norm(V31 - V3, inf));

disp("以6/1为参考节点的差别： " + norm(V3 - V2, inf));



