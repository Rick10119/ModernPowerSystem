%% �������A, �ڹ��������ɡ��õ�U, D, L
function [L, D, U] = factorize(A)
% ���뷽�� A
% ��� L, D, U

n = size(A, 1);% ����ά��
% ���ӷֽ�
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
L = tril(A);% �õ����� LU��ʽ�ľ���
D = diag(diag(A));
L  = L / D;% ���� LDU��ʽ

end