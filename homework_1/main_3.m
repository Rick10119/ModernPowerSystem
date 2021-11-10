%% 3.1 �ڽڵ� 5 ��ڵ� 8 ֮�����֧·
% ����Y����
Y = makeYbus(case14);
Y1 = Y; Y2 = Y;
n = length(Y);

branch58;% ��ȡ����
%% ����֧·
% �����·���� b/2 -> (5 ,8)
% ����������� (from, n+1)
M = zeros(n, 1);
M(from) = 1;
% ���֧·
Y1 = Y1 + M * y_b * M';

% % ����������� (to, n+1)
M = zeros(n, 1);
M(to) = 1;
% ���֧·
Y1 = Y1 + M * y_b * M';

% �����· y
M = zeros(n, 1);
M(from) = 1;
M(to) = -1;
Y1 = Y1 + M * y_l * M';

%% ����ڵ�
branch58;% ��ȡ����
y = [y_l + y_b, - y_l; ...
    - y_l, y_l + y_b];

M = zeros(n, 2);
M(from, 1) = 1;
M(to, 2) = 1;

Y2 = Y2 + M * y * M';

norm(Y1 - Y2, 1);

%% 3.2 ���ڽڵ� 11 ��ڵ� 12 ֮�����֧·��������֤��
branch1112;% ��ȡ����

% ����ڵ����
y = [y_l + y_b, - y_l; ...
    - y_l, y_l + y_b];

M = zeros(n, 2);
M(from, 1) = 1;
M(to, 2) = 1;

Y2 = Y2 + M * y * M';

%% �� 1 ����
% �����Լ�д��rankOne()����
[L, D, U] = factorize(Y);

branch58;% ��ȡ����
rankOneAdd;% ����

branch1112;% ��ȡ����
rankOneAdd;% ����

disp("�� 1 ������ " + norm(L * D * U - Y2, 1));


%% �ֲ��ٷֽ�
%
[L, D, U] = factorize(Y);
% �� 5 ��ʼΪ A22
index = 5;
delta_A22 = Y2(5:end, 5:end) - Y(5:end, 5:end);
A22_prime = L(5:end, 5:end) * D(5:end, 5:end) * U(5:end, 5:end);
A22_prime_tidle = A22_prime + delta_A22;
% �ֲ��ٷֽ�
[L22, D22, U22] = factorize(A22_prime_tidle);
% �������ӱ�
L(5:end, 5:end) = L22;
D(5:end, 5:end) = D22;
U(5:end, 5:end) = U22;

disp("�ֲ��ٷֽ��� " + norm(L * D * U - Y2, 1));

%% 3.3 ���������ӱ�������Ӻ�Ľڵ㵼�ɾ��� Y�����ͽڵ��迹���� Z����
Y_new = L * D * U;

% �����Լ�д�ĺ��� ldu2Z() ����Z
Z_new = ldu2Z(L, D, U);

% ���� Y1 ���� Z
Z = inv(Y1);% ԭ�����迹����
branch1112;% ��ȡ����
% ���֧·
M = zeros(n, 1);% ��������
M(from) = 1;
M(to) = -1;
c = inv(1/y_l + M' * Z * M);
Z = Z - Z * M * c* M' * Z;

% �����·���� 
% ��� (from, n+1)
M = zeros(n, 1);% ����������� (from, n+1)
M(from) = 1;
c = inv(1/y_b + M' * Z * M);
Z = Z - Z * M * c * M' * Z;% ��Ӳ���֧·
% ��� (to, n+1)
M = zeros(n, 1);% ����������� (to, n+1)
M(to) = 1;
c = inv(1/y_b + M' * Z * M);
Z = Z - Z * M * c * M' * Z;% ��Ӳ���֧·

disp("�������涨���� " + norm(Z - Z_new, 1));
