%% 输入参数A, 在工作区即可。得到U, D, L
function [L, D, U] = factorize(A)
% 输入方阵 A
% 输出 L, D, U

n = size(A, 1);% 矩阵维数
% 因子分解
for p = 1 : n-1
    for j = p+1 : n
        if A(p, j) ~= 0
            A(p, j) = A(p, j) / A(p, p);
            for i = p+1 : n
                if A(i, p) ~= 0
                    A(i, j) = A(i, j) - A(i, p) * A(p, j);
                end
            end
        end
    end
end

U = sparse(triu(A, 1) + eye(n));
L = tril(A);% 得到的是 LU格式的矩阵
D = diag(diag(A));
L  = L / D;% 化成 LDU格式

end