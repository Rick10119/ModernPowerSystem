%% 1��ţ��-����ѷ������⳱������ ��������
clc;clear;
casedata = case14; % ѡ��case
% casedata = case39;

bus = casedata.bus;
gen = casedata.gen;
%% ���� Y ����S �������ڵ�������������ʼ��
Ybus = makeYbus(casedata); % �ڵ㵼�ɾ���

Sbus = makeSbus(casedata.baseMVA, bus, gen); % ���ۻ�ע�븴����

[ref, pv, pq] = bustypes(bus, gen); % �ڵ���������

V0  = bus(:, 8) .* exp(1j * pi/180 * bus(:, 9));% ��ʼ����ѹ�����bus �и�����

%% �����Լ�д�� NR ����⳱��

[V1, success1, iterations1] = myNewtonpf(Ybus, Sbus, V0, ref, pv, pq);

%% ����Ƚϣ������Դ���runpf�е� newtonpf��

mpopt = mpoption;
mpopt.pf.alg = 'NR'; % ����ѡ NR ��

[MVAbase2, bus2, gen2, branch2, success2, et2] = ...
    runpf(casedata, mpopt);% �����Դ���runpf�е� newtonpf
V2 =  bus2(:, 8) .* exp(1j * pi/180 * bus2(:, 9)); % �����ѹ����

disp("myNewtonpf��newtonpf�Ĳ��norm(V1 - V2, inf):  " + norm(V1 - V2, inf));


%% �޸Ľڵ�����
ref = 6; % ƽ��ڵ�ӽڵ� 1 �޸�Ϊ�ڵ� 6
pv(find(pv == 6)) = 1; % �ڵ� 1 ��Ϊ PV �ڵ�
pv = sort(pv); % ��������
[V31, success31, iterations31] = myNewtonpf(Ybus, Sbus, V0, ref, pv, pq);

% ���� NR ����⳱��

casedata.bus(1,2) = 2;
casedata.bus(6,2) = 3;
[MVAbase3, bus3, gen3, branch3, success3, et3] = ...
    runpf(casedata, mpopt);% �����Դ���runpf�е� newtonpf
V3 =  bus3(:, 8) .* exp(1j * pi/180 * bus3(:, 9));

disp("myNewtonpf��newtonpf�Ĳ��norm(V31 - V3, inf)�� " + norm(V31 - V3, inf));

disp("��6/1Ϊ�ο��ڵ�Ĳ�� " + norm(V3 - V2, inf));



