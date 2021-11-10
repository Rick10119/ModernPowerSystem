%% 1.3 ֧·׷�ӷ����ɽڵ��迹���� Z
mpc = case14; % ��ȡ14�ڵ�����

% ĸ�ߺ�֧·����
n = length(mpc.bus);
m = length(mpc.branch);

% �������֧·�Ƿ��Ѿ����
is_added = zeros(length(mpc.branch), 1); 

%% ��һ��֧·��1,2�����⴦��
i1 = find(mpc.branch(:, 1) == 1); %���ҵ���index
i2 = find(mpc.branch(i1, 2) == 2);

z_a = 1/ (1/2 * mpc.branch(i2, 5) * 1j); % b/2 ��Ӧ���迹
Z = z_a;% ֱ�����Ϊ��һ��Ԫ�� (1,n+1)������Z

z_a = mpc.branch(i2, 3 : 4) * [1, 1j].';% ֧·�迹
Z = [Z, Z(:, 1); ...
    Z(:, 1).', Z(1, 1) + z_a];
% ���b/2 ��Ӧ���迹��(2, n+1)
M_a =[0; 1];
z_a = 1/ (1/2 * mpc.branch(i2, 5) * 1j);% ֧·�迹
z_aa = z_a + M_a' * Z * M_a;
Z = Z - Z * M_a * inv(z_aa) * M_a' * Z;

is_added(i2) = 1;%��Ϊ�Ѿ�����

%% ����ʣ�µ�

while ~isempty(find(is_added == 0))  % ��ӵ����нڵ㶼������Ϊֹ
    
    for idx = 1 : m  %ɨ��һ������֧·
        branch = mpc.branch(idx, :);
        
        if is_added(idx) ==1 || branch(2)  > size(Z, 1) + 1% ������򲻹ܣ��������о���+1Ҳ�Ȳ���
            continue;
        end
        
        %% �����·
        z_a = branch(3 : 4) * [1, 1j].';% ֧·�迹
        
        % �����֧
        if branch(2)  == size(Z, 1) + 1
            
            t = branch(9);
            
            if t ~= 0 % ��ѹ��(������������)
                Z = [Z, Z(:, branch(1)) / t; ...
                    Z(:, branch(1)).' / t, Z(branch(1), branch(1))/ t^2+ z_a];
            else % �Ǳ�ѹ��
                Z = [Z, Z(:, branch(1)); ...
                    Z(:, branch(1)).', Z(branch(1), branch(1)) + z_a];
            end
            
        % �����֧
        else
            
            % ��������
            M_a = zeros(size(Z, 1), 1);
            M_a(branch(1)) = 1;
            M_a(branch(2)) = -1;

            % ��ѹ��(������������)
            t = branch(9);
            if t ~= 0
                M_a(branch(1)) = 1 / t;
            end
            
            z_a = branch(3 : 4) * [1, 1j].';% ֧·�迹
            z_aa = z_a + M_a' * Z * M_a;
            Z = Z - Z * M_a * inv(z_aa) * M_a' * Z;
            
        end
        
        %% �����·���� b/2 -> (to, n+1)
        if branch(5) ~=0
            z_a = 1/ (1/2 * branch(5) * 1j); % b/2 ��Ӧ���迹
            % ��� (from, n+1)
            M_a = zeros(size(Z, 1), 1);% ����������� (from, n+1)
            M_a(branch(1)) = 1;
            z_aa = z_a + M_a' * Z * M_a;
            Z = Z - Z * M_a * inv(z_aa) * M_a' * Z;% ��Ӳ���֧·
            
            % ��� (to, n+1)
            M_a = zeros(size(Z, 1), 1);% ����������� (to, n+1)
            M_a(branch(2)) = 1;
            z_aa = z_a + M_a' * Z * M_a;
            Z = Z - Z * M_a * inv(z_aa) * M_a' * Z;% ��Ӳ���֧·
        end
        
        is_added(idx) = 1;
        
    end
end


%% ���ĸ�߽ӵ�֧·
for idx  = 1 : n
    
    % �ӵص���
    y_shunt = mpc.bus(idx, 5:6) * [1, 1j].' / mpc.baseMVA;
    
    if abs(y_shunt) ~= 0
        
        % ��������
        M_a = zeros(n, 1);
        M_a(idx) = 1;
        
        % ��Ӳ���֧·
        z_a = 1 / y_shunt;
        z_aa = z_a + M_a' * Z * M_a;
        Z = Z - Z * M_a * inv(z_aa) * M_a' * Z;

    end
    
end

Y = makeYbus(case14);
disp("Z ��ֱ�������� " + norm(inv(Y) - Z, 1));


