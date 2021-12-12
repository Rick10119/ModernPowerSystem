%% 	开断 IEEE 39 节点系统中的支路（25, 26）
% 编写计算支路开断分布因子的程序，计算开断后的潮流变化。 
clc;clear;
mpc = case39; % 选择case
% testCase = case39;
% LO = [25, 26; 10, 13];% 控制开断顺序
LO = [10, 13; 25, 26];

%% 计算支路开断分布因子
LODF1 = myMakeLODF(mpc);

% 与makeLODF对比
H = makePTDF(mpc);
LODF2 = makeLODF(mpc.branch, H);

% 计算潮流1
[~, ~, ~, branch1, ~, ~] = runpf(mpc);

% 开断（25, 26）支路
idx_1 = find(mpc.branch(:,1) == LO(1, 1));
idx_2 =  idx_1(find(mpc.branch(idx_1, 2) == LO(1, 2)));% 这是第 idx_2条支路
mpc.branch(idx_2, 11) = 0;% 开断该支路（支路status设为0）

% 新潮流2
[~, ~, ~, branch2, ~, ~] = runpf(mpc);

% 支路潮流变化(有功在14列)
delta_P_cal = branch2(:, 14) - branch1(:, 14);
delta_P_est1 =  LODF1(:, idx_2) * branch1(idx_2, 14);
delta_P_est2 =  LODF2(:, idx_2) * branch1(idx_2, 14);

disp("myMakeLODF与实际开断后潮流变化之差: norm(delta_P_cal - delta_P_est1, inf) =");
disp(norm(delta_P_cal - delta_P_est1, inf));
disp("makeLODF与实际开断计算有功潮流之差: norm(delta_P_cal - delta_P_est2, inf) ="); 
disp(norm(delta_P_cal - delta_P_est2, inf));


%% 开断多条潮流
% 在已经开断(25, 26)的情况下，重新计算LODF
LODF1 = myMakeLODF(mpc);% 我的程序

H = makePTDF(mpc);
LODF2 = makeLODF(mpc.branch, H);% makeLODF


% 上面已经打开了(25, 26)，现在再打开(10, 13)
idx_3 = find(mpc.branch(:,1) == LO(2, 1));
idx_4 =  idx_3(find(mpc.branch(idx_3, 2) == LO(2, 2)));% 这是第 idx_2条支路
mpc.branch(idx_4, 11) = 0;% 开断该支路（支路status设为0）

% 新潮流3
[~, ~, ~, branch3, ~, ~] = runpf(mpc);

% % 这一次的变化
% delta_P_cal = branch3(:, 14) - branch2(:, 14);
% delta_P_est1 =  LODF1(:, idx_4) * branch2(idx_4, 14);
% delta_P_est2 =  LODF2(:, idx_4) * branch2(idx_4, 14);
% 
% disp("开断第二条，myMakeLODF与开断后潮流变化之差: norm(delta_P_cal - delta_P_est1, inf) =");
% disp(norm(delta_P_cal - delta_P_est1, inf));
% disp("开断第二条，makeLODF与实际开断计算有功潮流之差: norm(delta_P_cal - delta_P_est2, inf) ="); 
% disp(norm(delta_P_cal - delta_P_est2, inf));

% 都用第一次潮流计算
% 相对无开断，支路潮流变化(有功在14列)
delta_P_cal = branch3(:, 14) - branch1(:, 14);
delta_P_est1 =  delta_P_est1 + LODF1(:, idx_4) * branch1(idx_4, 14);% 加上第二条线路开断影响
delta_P_est2 =  delta_P_est2 + LODF2(:, idx_4) * branch1(idx_4, 14);% 加上第二条线路开断影响

disp("开断第二条，myMakeLODF与开断后潮流变化之差: norm(delta_P_cal - delta_P_est1, inf) =");
disp(norm(delta_P_cal - delta_P_est1, inf));
disp("开断第二条，makeLODF与实际开断计算有功潮流之差: norm(delta_P_cal - delta_P_est2, inf) ="); 
disp(norm(delta_P_cal - delta_P_est2, inf));

% 第二次开断的影响用第二次的潮流计算
% % 相对无开断，支路潮流变化(有功在14列)
% delta_P_cal = branch3(:, 14) - branch1(:, 14);
% delta_P_est1 =  delta_P_est1 + LODF1(:, idx_4) * branch2(idx_4, 14);% 加上第二条线路开断影响
% delta_P_est2 =  delta_P_est2 + LODF2(:, idx_4) * branch2(idx_4, 14);% 加上第二条线路开断影响
% 
% disp("开断第二条，myMakeLODF与开断后潮流变化之差: norm(delta_P_cal - delta_P_est1, inf) =");
% disp(norm(delta_P_cal - delta_P_est1, inf));
% disp("开断第二条，makeLODF与实际开断计算有功潮流之差: norm(delta_P_cal - delta_P_est2, inf) ="); 
% disp(norm(delta_P_cal - delta_P_est2, inf));


