%% 连续回代法重新生成节点阻抗矩阵 Z
function Z = ldu2Z(L, D, U)
n = length(L);
Z = [];

for idx = 1 : n % 逐列求解 Z
    % 构造独立矢量，（I的对应列）
    b = zeros(n, 1);
    b(idx) = 1;
    % 解出 x
    % 前代
    z = b;
    for j = 1 : n-1
        if z(j) ~= 0
            for i = j + 1 : n
                if L(i, j) ~= 0
                    z(i) = z(i) - L(i, j) * z(j);
                end
            end
        end
    end
    
    % 除法
    y = z;
    for i = 1 : n
        y(i) = y(i) / D(i, i);
    end
    
    % 回代
    x = y;
    for i = n - 1 : -1: 1
        for j = n : -1: i + 1
            if U(i, j) ~= 0 && x(j) ~= 0
                x(i) = x(i) - U(i, j) * x(j);
            end
        end  
    end
   
    
    % 构造Z
    Z = [Z, x];
end