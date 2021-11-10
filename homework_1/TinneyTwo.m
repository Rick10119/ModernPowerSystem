%% 编号方法 - Tinney-2
function [bus_new, branch_new] = TinneyTwo(baseMVA, bus, branch)

%
% INPUT DATA:
%   bus, branch original bus and branch matrices in the same format as mpc.bus, mpc.branch 
%
% OUTPUT DATA:
%   bus_new, branch_new reordered bus and branch matrices in the same format as mpc.bus, mpc.branch
%

n = length(bus);
m = length(branch);

% 统计节点出线度（只考虑支路）
bus_degree = zeros(size(bus, 1), 1);
% 编号
bus_order = zeros(size(bus, 1), 1);
for idx = 1 : m %遍历支路
    bus_degree(branch(idx, 1)) =  bus_degree(branch(idx, 1)) + 1;
    bus_degree(branch(idx, 2)) =  bus_degree(branch(idx, 2)) + 1;
end
bd = bus_degree;
% 度1节点（任意一个）作为第一个
temp = find(bus_degree == min(bus_degree));
bus_order(temp(1)) = 1;

%% 从度1节点开始： 编号，消去，修正
% 生成模拟的 U_m, 表示是否有元素
Y = makeYbus(baseMVA, bus, branch);
Y_m = zeros(size(Y));
Y_m(find(Y ~= 0)) = 1;
for idx = 1 : n - 1
    % 修正
    idx_original = find(bus_order == idx);% 当前idx的bus的原来的编号
    
    % 修改 Y_m 矩阵
    for jdx1 = 1 : n - 1
        if Y_m(idx_original, jdx1) ~= 0 % 找到一个非零元
            for jdx2 = jdx1 + 1 : n % 找下一个非零元
                if Y_m(idx_original, jdx2) ~= 0
                    % 添加度， 第一个非零元对应的节点
                    if Y_m(jdx1, jdx2) == 0% 添加非零元
                        bus_degree(jdx1) =  bus_degree(jdx1) + 1;% 修改度
                        bus_degree(jdx2) =  bus_degree(jdx2) + 1;
                        Y_m(jdx1, jdx2) = 1;% 添加非零元
                        Y_m(jdx2, jdx1) = 1;
                    end
                end
            end
        end
    end
    %     sparse(Y_m - Y_m1)
    %     bus_degree - bd
    
    % 在Y_m中消去当前节点
    Y_m(idx_original, :) = zeros(1, n);
    Y_m(:, idx_original) = zeros(n, 1);
    bus_degree(idx_original) = inf;
    
    % 找下一个节点
    % 刚消去的节点的度不能再去，所以取一个大数
    
    temp = find(bus_degree == min(bus_degree));
    bus_order(temp(1)) = idx + 1;
end

%% 修改branch编号
% 参照前面得到的 bus_order
for idx = 1 : m
    branch(idx, 1) = bus_order(branch(idx, 1));
    branch(idx, 2) = bus_order(branch(idx, 2));
    if branch(idx, 1) > branch(idx, 2) % 保持小号在前
        temp = branch(idx, 1);
        branch(idx, 1) = branch(idx, 2);
        branch(idx, 2) = temp;
        if branch(idx, 9) ~= 0 % 变比反过来
            branch(idx, 9) = 1 / branch(idx, 9);
        end
    end
end

 % 修改bus编号
 for idx = 1 : n
     bus(idx, 1) = bus_order(bus(idx, 1));
 end
% 重新排序
branch_new = sortrows(branch, 1);
bus_new = sortrows(bus, 1);

end
    