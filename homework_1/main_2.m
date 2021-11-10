%% 2.1 �ڵ㵼�ɾ��� Y ���� LDU �ֽ�
% ����Y����
Y = makeYbus(case14);

%% LU�ֽ�
A = Y;
n = size(A, 1);

%�Ա��Դ���lu�ֽ�
[L1, U1] = lu(A);
D1 = diag(diag(U1));
U1 = D1 \ U1;
norm(L1 * D1 * U1 - Y, 1);

% �Լ�д�����ӷֽ⣨���� factorize(����
[L2, D2, U2] = factorize(A);
norm(L2 * D2 * U2 - Y, 1);

%% 2.2 ���� Tinney-2 ��ŷ�����Tinney-3 ���, �Ա�LDU�ֽ�
% �Լ�д�� TinneyTwo(), TinneyThree() ����
mpc = case14;% ��ȡ����Ϊmpc

test_times = 1;% ִ�д���

%% ���Ա������ʱ��
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

%% ����LDU�ֽ�����ʱ��
tic
for i = 1 : test_times
    [L1, D1, U1] = factorize(makeYbus(case14));% ԭʼ���
end
t_factorize_1 = toc;

tic
for i = 1 : test_times
    [L2, D2, U2] = factorize(makeYbus(mpc.baseMVA, bus_new2, branch_new2));% Tinney-2���
end
t_factorize_2 = toc;

tic
for i = 1 : test_times
    [L3, D3, U3] = factorize(makeYbus(mpc.baseMVA, bus_new3, branch_new3));% Tinney-3���
end
t_factorize_3 = toc;

%% ͳ�Ʒ���Ԫ����
nofNZ1 = length(find(L1 ~= 0));
nofNZ2 = length(find(L2 ~= 0));
nofNZ3 = length(find(L3 ~= 0));

%% 2.3 ���� LDU �ֽ�Ľ�������������ش����������ɽڵ��迹���� Z
[L, D, U] = factorize(makeYbus(case14));
 
% �����Լ�д�ĺ��� ldu2Z() ����Z
Z = ldu2Z(L, D, U);

disp("LDU����Z�� " + norm(inv(Y) - Z, 1));

