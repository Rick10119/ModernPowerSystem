%% ��ŷ��� - Tinney-2
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

% ͳ�ƽڵ���߶ȣ�ֻ����֧·��
bus_degree = zeros(size(bus, 1), 1);
% ���
bus_order = zeros(size(bus, 1), 1);
for idx = 1 : m %����֧·
    bus_degree(branch(idx, 1)) =  bus_degree(branch(idx, 1)) + 1;
    bus_degree(branch(idx, 2)) =  bus_degree(branch(idx, 2)) + 1;
end
bd = bus_degree;
% ��1�ڵ㣨����һ������Ϊ��һ��
temp = find(bus_degree == min(bus_degree));
bus_order(temp(1)) = 1;

%% �Ӷ�1�ڵ㿪ʼ�� ��ţ���ȥ������
% ����ģ��� U_m, ��ʾ�Ƿ���Ԫ��
Y = makeYbus(baseMVA, bus, branch);
Y_m = zeros(size(Y));
Y_m(find(Y ~= 0)) = 1;
for idx = 1 : n - 1
    % ����
    idx_original = find(bus_order == idx);% ��ǰidx��bus��ԭ���ı��
    
    % �޸� Y_m ����
    for jdx1 = 1 : n - 1
        if Y_m(idx_original, jdx1) ~= 0 % �ҵ�һ������Ԫ
            for jdx2 = jdx1 + 1 : n % ����һ������Ԫ
                if Y_m(idx_original, jdx2) ~= 0
                    % ��Ӷȣ� ��һ������Ԫ��Ӧ�Ľڵ�
                    if Y_m(jdx1, jdx2) == 0% ��ӷ���Ԫ
                        bus_degree(jdx1) =  bus_degree(jdx1) + 1;% �޸Ķ�
                        bus_degree(jdx2) =  bus_degree(jdx2) + 1;
                        Y_m(jdx1, jdx2) = 1;% ��ӷ���Ԫ
                        Y_m(jdx2, jdx1) = 1;
                    end
                end
            end
        end
    end
    %     sparse(Y_m - Y_m1)
    %     bus_degree - bd
    
    % ��Y_m����ȥ��ǰ�ڵ�
    Y_m(idx_original, :) = zeros(1, n);
    Y_m(:, idx_original) = zeros(n, 1);
    bus_degree(idx_original) = inf;
    
    % ����һ���ڵ�
    % ����ȥ�Ľڵ�ĶȲ�����ȥ������ȡһ������
    
    temp = find(bus_degree == min(bus_degree));
    bus_order(temp(1)) = idx + 1;
end

%% �޸�branch���
% ����ǰ��õ��� bus_order
for idx = 1 : m
    branch(idx, 1) = bus_order(branch(idx, 1));
    branch(idx, 2) = bus_order(branch(idx, 2));
    if branch(idx, 1) > branch(idx, 2) % ����С����ǰ
        temp = branch(idx, 1);
        branch(idx, 1) = branch(idx, 2);
        branch(idx, 2) = temp;
        if branch(idx, 9) ~= 0 % ��ȷ�����
            branch(idx, 9) = 1 / branch(idx, 9);
        end
    end
end

 % �޸�bus���
 for idx = 1 : n
     bus(idx, 1) = bus_order(bus(idx, 1));
 end
% ��������
branch_new = sortrows(branch, 1);
bus_new = sortrows(bus, 1);

end
    