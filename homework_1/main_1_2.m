%% 1.3 支路追加法生成节点阻抗矩阵 Z
mpc = case14; % 读取14节点数据

% 母线和支路数量
n = length(mpc.bus);
m = length(mpc.branch);

% 用来标记支路是否已经添加
is_added = zeros(length(mpc.branch), 1); 

%% 第一个支路（1,2）特殊处理，
i1 = find(mpc.branch(:, 1) == 1); %先找到其index
i2 = find(mpc.branch(i1, 2) == 2);

z_a = 1/ (1/2 * mpc.branch(i2, 5) * 1j); % b/2 对应的阻抗
Z = z_a;% 直接添加为第一个元素 (1,n+1)，加入Z

z_a = mpc.branch(i2, 3 : 4) * [1, 1j].';% 支路阻抗
Z = [Z, Z(:, 1); ...
    Z(:, 1).', Z(1, 1) + z_a];
% 添加b/2 对应的阻抗到(2, n+1)
M_a =[0; 1];
z_a = 1/ (1/2 * mpc.branch(i2, 5) * 1j);% 支路阻抗
z_aa = z_a + M_a' * Z * M_a;
Z = Z - Z * M_a * inv(z_aa) * M_a' * Z;

is_added(i2) = 1;%记为已经加入

%% 加入剩下的

while ~isempty(find(is_added == 0))  % 添加到所有节点都在里面为止
    
    for idx = 1 : m  %扫描一遍所有支路
        branch = mpc.branch(idx, :);
        
        if is_added(idx) ==1 || branch(2)  > size(Z, 1) + 1% 已添加则不管，大于现有矩阵+1也先不管
            continue;
        end
        
        %% 添加线路
        z_a = branch(3 : 4) * [1, 1j].';% 支路阻抗
        
        % 添加树支
        if branch(2)  == size(Z, 1) + 1
            
            t = branch(9);
            
            if t ~= 0 % 变压器(不考虑移相器)
                Z = [Z, Z(:, branch(1)) / t; ...
                    Z(:, branch(1)).' / t, Z(branch(1), branch(1))/ t^2+ z_a];
            else % 非变压器
                Z = [Z, Z(:, branch(1)); ...
                    Z(:, branch(1)).', Z(branch(1), branch(1)) + z_a];
            end
            
        % 添加连支
        else
            
            % 关联向量
            M_a = zeros(size(Z, 1), 1);
            M_a(branch(1)) = 1;
            M_a(branch(2)) = -1;

            % 变压器(不考虑移相器)
            t = branch(9);
            if t ~= 0
                M_a(branch(1)) = 1 / t;
            end
            
            z_a = branch(3 : 4) * [1, 1j].';% 支路阻抗
            z_aa = z_a + M_a' * Z * M_a;
            Z = Z - Z * M_a * inv(z_aa) * M_a' * Z;
            
        end
        
        %% 添加线路导纳 b/2 -> (to, n+1)
        if branch(5) ~=0
            z_a = 1/ (1/2 * branch(5) * 1j); % b/2 对应的阻抗
            % 添加 (from, n+1)
            M_a = zeros(size(Z, 1), 1);% 构造关联矩阵 (from, n+1)
            M_a(branch(1)) = 1;
            z_aa = z_a + M_a' * Z * M_a;
            Z = Z - Z * M_a * inv(z_aa) * M_a' * Z;% 添加并联支路
            
            % 添加 (to, n+1)
            M_a = zeros(size(Z, 1), 1);% 构造关联矩阵 (to, n+1)
            M_a(branch(2)) = 1;
            z_aa = z_a + M_a' * Z * M_a;
            Z = Z - Z * M_a * inv(z_aa) * M_a' * Z;% 添加并联支路
        end
        
        is_added(idx) = 1;
        
    end
end


%% 添加母线接地支路
for idx  = 1 : n
    
    % 接地导纳
    y_shunt = mpc.bus(idx, 5:6) * [1, 1j].' / mpc.baseMVA;
    
    if abs(y_shunt) ~= 0
        
        % 关联矩阵
        M_a = zeros(n, 1);
        M_a(idx) = 1;
        
        % 添加并联支路
        z_a = 1 / y_shunt;
        z_aa = z_a + M_a' * Z * M_a;
        Z = Z - Z * M_a * inv(z_aa) * M_a' * Z;

    end
    
end

Y = makeYbus(case14);
disp("Z 与直接求逆差别： " + norm(inv(Y) - Z, 1));


