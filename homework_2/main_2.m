%% 	���� IEEE 39 �ڵ�ϵͳ�е�֧·��25, 26��
% ��д����֧·���Ϸֲ����ӵĳ��򣬼��㿪�Ϻ�ĳ����仯�� 
clc;clear;
mpc = case39; % ѡ��case
% testCase = case39;
% LO = [25, 26; 10, 13];% ���ƿ���˳��
LO = [10, 13; 25, 26];

%% ����֧·���Ϸֲ�����
LODF1 = myMakeLODF(mpc);

% ��makeLODF�Ա�
H = makePTDF(mpc);
LODF2 = makeLODF(mpc.branch, H);

% ���㳱��1
[~, ~, ~, branch1, ~, ~] = runpf(mpc);

% ���ϣ�25, 26��֧·
idx_1 = find(mpc.branch(:,1) == LO(1, 1));
idx_2 =  idx_1(find(mpc.branch(idx_1, 2) == LO(1, 2)));% ���ǵ� idx_2��֧·
mpc.branch(idx_2, 11) = 0;% ���ϸ�֧·��֧·status��Ϊ0��

% �³���2
[~, ~, ~, branch2, ~, ~] = runpf(mpc);

% ֧·�����仯(�й���14��)
delta_P_cal = branch2(:, 14) - branch1(:, 14);
delta_P_est1 =  LODF1(:, idx_2) * branch1(idx_2, 14);
delta_P_est2 =  LODF2(:, idx_2) * branch1(idx_2, 14);

disp("myMakeLODF��ʵ�ʿ��Ϻ����仯֮��: norm(delta_P_cal - delta_P_est1, inf) =");
disp(norm(delta_P_cal - delta_P_est1, inf));
disp("makeLODF��ʵ�ʿ��ϼ����й�����֮��: norm(delta_P_cal - delta_P_est2, inf) ="); 
disp(norm(delta_P_cal - delta_P_est2, inf));


%% ���϶�������
% ���Ѿ�����(25, 26)������£����¼���LODF
LODF1 = myMakeLODF(mpc);% �ҵĳ���

H = makePTDF(mpc);
LODF2 = makeLODF(mpc.branch, H);% makeLODF


% �����Ѿ�����(25, 26)�������ٴ�(10, 13)
idx_3 = find(mpc.branch(:,1) == LO(2, 1));
idx_4 =  idx_3(find(mpc.branch(idx_3, 2) == LO(2, 2)));% ���ǵ� idx_2��֧·
mpc.branch(idx_4, 11) = 0;% ���ϸ�֧·��֧·status��Ϊ0��

% �³���3
[~, ~, ~, branch3, ~, ~] = runpf(mpc);

% % ��һ�εı仯
% delta_P_cal = branch3(:, 14) - branch2(:, 14);
% delta_P_est1 =  LODF1(:, idx_4) * branch2(idx_4, 14);
% delta_P_est2 =  LODF2(:, idx_4) * branch2(idx_4, 14);
% 
% disp("���ϵڶ�����myMakeLODF�뿪�Ϻ����仯֮��: norm(delta_P_cal - delta_P_est1, inf) =");
% disp(norm(delta_P_cal - delta_P_est1, inf));
% disp("���ϵڶ�����makeLODF��ʵ�ʿ��ϼ����й�����֮��: norm(delta_P_cal - delta_P_est2, inf) ="); 
% disp(norm(delta_P_cal - delta_P_est2, inf));

% ���õ�һ�γ�������
% ����޿��ϣ�֧·�����仯(�й���14��)
delta_P_cal = branch3(:, 14) - branch1(:, 14);
delta_P_est1 =  delta_P_est1 + LODF1(:, idx_4) * branch1(idx_4, 14);% ���ϵڶ�����·����Ӱ��
delta_P_est2 =  delta_P_est2 + LODF2(:, idx_4) * branch1(idx_4, 14);% ���ϵڶ�����·����Ӱ��

disp("���ϵڶ�����myMakeLODF�뿪�Ϻ����仯֮��: norm(delta_P_cal - delta_P_est1, inf) =");
disp(norm(delta_P_cal - delta_P_est1, inf));
disp("���ϵڶ�����makeLODF��ʵ�ʿ��ϼ����й�����֮��: norm(delta_P_cal - delta_P_est2, inf) ="); 
disp(norm(delta_P_cal - delta_P_est2, inf));

% �ڶ��ο��ϵ�Ӱ���õڶ��εĳ�������
% % ����޿��ϣ�֧·�����仯(�й���14��)
% delta_P_cal = branch3(:, 14) - branch1(:, 14);
% delta_P_est1 =  delta_P_est1 + LODF1(:, idx_4) * branch2(idx_4, 14);% ���ϵڶ�����·����Ӱ��
% delta_P_est2 =  delta_P_est2 + LODF2(:, idx_4) * branch2(idx_4, 14);% ���ϵڶ�����·����Ӱ��
% 
% disp("���ϵڶ�����myMakeLODF�뿪�Ϻ����仯֮��: norm(delta_P_cal - delta_P_est1, inf) =");
% disp(norm(delta_P_cal - delta_P_est1, inf));
% disp("���ϵڶ�����makeLODF��ʵ�ʿ��ϼ����й�����֮��: norm(delta_P_cal - delta_P_est2, inf) ="); 
% disp(norm(delta_P_cal - delta_P_est2, inf));


