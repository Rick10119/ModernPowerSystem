function [V, converged, i] = myNewtonpf(Ybus, Sbus, V0, ref, pv, pq, mpopt)
%NEWTONPF  Solves power flow using full Newton's method (power/polar)
%
%   NR 方法解节点电压（极坐标形式）
%   输入
%       YBUS  - full system admittance matrix (for all buses)
%       SBUS  - complex bus power injection vector (for all buses)
%       V0    - initial vector of complex bus voltages
%       REF   - bus index of reference bus (voltage ang reference & gen slack)
%       PV    - vector of bus indices for PV buses
%       PQ    - vector of bus indices for PQ buses
%

%% 默认设置
if nargin < 7
    mpopt = mpoption;
end

tol         = mpopt.pf.tol; % 精度
max_it      = mpopt.pf.nr.max_it; % 最大迭代次数

%% 初始化
converged = 0;
i = 0;
V = V0;
Va = angle(V); % 初始电压相角
Vm = abs(V); % 初始电压幅值

%% 计算初始误差
mis = V .* conj(Ybus * V) - Sbus;
Fx = [   real(mis([pv; pq]));
    imag(mis(pq))   ];

if norm(Fx, inf) < tol % 收敛
    converged = 1;
    fprintf('\nmyNewtonpf''s method power flow (power balance, polar) converged by the initial voltage!', i);
end


%% 开始迭代
while (~converged && i < max_it)
    i = i + 1; % 迭代次数
    
    %% 计算雅可比矩阵
    % 参考 dSbus_dV.m
    dSbus_dVa = 1j * diag(V) * conj(diag(Ybus * V) - Ybus * diag(V));                     % dSbus/dVa
    dSbus_dVm = diag(V) * conj(Ybus * diag(V./abs(V))) + conj(diag(Ybus * V)) * diag(V./abs(V));    % dSbus/dVm
    
    J = [real(dSbus_dVa([pv; pq], [pv; pq])), real(dSbus_dVm([pv; pq], pq)); ...
        imag(dSbus_dVa(pq, [pv; pq])), imag(dSbus_dVm(pq, pq))];
    
    %% 更新 x
    dx = J \ (- Fx);
    
    nofpv = length(pv);
    nofpq = length(pq);
    Va(pv) = Va(pv) + dx(1 : nofpv);
    
    Va(pq) = Va(pq) + dx(1+ nofpv : nofpv + nofpq); % 从 dx 中读取相应的变化量
    Vm(pq) = Vm(pq) + dx(1+ nofpv + nofpq : nofpv + 2 * nofpq);
    
    V = Vm .* exp(1j * Va);% 新的复电压向量
    Vm = abs(V);
    Va = angle(V);
    
    %% 检查是否收敛
    mis = V .* conj(Ybus * V) - Sbus;
    Fx = [   real(mis([pv; pq]));
        imag(mis(pq))   ];

    if norm(Fx, inf) < tol % 收敛
        converged = 1;
        fprintf('\nmyNewtonpf''s method power flow (power balance, polar) converged in %d iterations.\n', i);
    end
    
end % end while

if ~converged % 最大次数内未收敛
    fprintf('\n myNewtonpf''s method power flow (power balance, polar) did not converge in %d iterations.\n', i);
end
