%% ���� IEEE 14 �ڵ�ϵͳ���ɽڵ㲻�����ɾ��� Y0
mpc = case14; % ��ȡ14�ڵ�����

% ĸ�ߺ�֧·����
n = length(mpc.bus);
m = length(mpc.branch);

% ��ʼ��
Y0 = zeros(n+1, n+1);

for idx  = 1 : m % ���branch ���
    
    % �����·���� b/2 -> (from, n+1), (to, n+1)
    y_l = 1/2 * mpc.branch(idx, 5) * 1j; % b/2
    % ����������� (from, n+1)
    M_a = zeros(n + 1, 1);
    M_a(mpc.branch(idx, 1)) = 1;
    M_a(n + 1) = -1;
    % ���֧·
    Y0 = Y0 + M_a * y_l * M_a';
    
    % ����������� (to, n+1)
    M_a = zeros(n + 1, 1);
    M_a(mpc.branch(idx, 2)) = 1;
    M_a(n + 1) = -1;
    % ���֧·
    Y0 = Y0 + M_a * y_l * M_a';
    
    % ���֧·�絼
     y_b = 1/ (mpc.branch(idx, 3:4) * [1, 1j].' );% �絼��branch��1/(r + ix)
    % ����������� (from, to)
    M_a = zeros(n + 1, 1);
    M_a(mpc.branch(idx, 1)) = 1; % �ڵ�����branch �� from(1), to(2)
    M_a(mpc.branch(idx, 2)) = -1;
    % ��ѹ��(������������)
    t = mpc.branch(idx, 9);
    if t ~= 0
        M_a(mpc.branch(idx, 1)) = 1 / t;
    end
    % ���֧·
    Y0 = Y0 + M_a * y_b * M_a';
end


% ����ĸ�ߵĽӵ�֧·
for idx  = 1 : n
    
    % �ӵص���
    y_shunt = mpc.bus(idx, 5:6) * [1, 1j].' / mpc.baseMVA;
    
    % ��������
    M_a = zeros(n + 1, 1);
    M_a(idx) = 1;
    M_a(length(mpc.bus) + 1) = -1;
    
    
    
    % ���֧·
    Y0 = Y0 + M_a * y_shunt * M_a';
    
end


%% 1.1 �Ե�Ϊ�ο��ڵ����ɽڵ㵼�ɾ��� Y

Y = Y0(1: n, 1:n);

%% 1.2 ʹ��makeYbus()
Y_makeYbus = makeYbus(mpc);

% ��֤
disp("Y ��makeYbus��� " + norm(Y - Y_makeYbus, 1));
