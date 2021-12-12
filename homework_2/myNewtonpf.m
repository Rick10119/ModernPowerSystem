function [V, converged, i] = myNewtonpf(Ybus, Sbus, V0, ref, pv, pq, mpopt)
%NEWTONPF  Solves power flow using full Newton's method (power/polar)
%
%   NR ������ڵ��ѹ����������ʽ��
%   ����
%       YBUS  - full system admittance matrix (for all buses)
%       SBUS  - complex bus power injection vector (for all buses)
%       V0    - initial vector of complex bus voltages
%       REF   - bus index of reference bus (voltage ang reference & gen slack)
%       PV    - vector of bus indices for PV buses
%       PQ    - vector of bus indices for PQ buses
%

%% Ĭ������
if nargin < 7
    mpopt = mpoption;
end

tol         = mpopt.pf.tol; % ����
max_it      = mpopt.pf.nr.max_it; % ����������

%% ��ʼ��
converged = 0;
i = 0;
V = V0;
Va = angle(V); % ��ʼ��ѹ���
Vm = abs(V); % ��ʼ��ѹ��ֵ

%% �����ʼ���
mis = V .* conj(Ybus * V) - Sbus;
Fx = [   real(mis([pv; pq]));
    imag(mis(pq))   ];

if norm(Fx, inf) < tol % ����
    converged = 1;
    fprintf('\nmyNewtonpf''s method power flow (power balance, polar) converged by the initial voltage!', i);
end


%% ��ʼ����
while (~converged && i < max_it)
    i = i + 1; % ��������
    
    %% �����ſɱȾ���
    % �ο� dSbus_dV.m
    dSbus_dVa = 1j * diag(V) * conj(diag(Ybus * V) - Ybus * diag(V));                     % dSbus/dVa
    dSbus_dVm = diag(V) * conj(Ybus * diag(V./abs(V))) + conj(diag(Ybus * V)) * diag(V./abs(V));    % dSbus/dVm
    
    J = [real(dSbus_dVa([pv; pq], [pv; pq])), real(dSbus_dVm([pv; pq], pq)); ...
        imag(dSbus_dVa(pq, [pv; pq])), imag(dSbus_dVm(pq, pq))];
    
    %% ���� x
    dx = J \ (- Fx);
    
    nofpv = length(pv);
    nofpq = length(pq);
    Va(pv) = Va(pv) + dx(1 : nofpv);
    
    Va(pq) = Va(pq) + dx(1+ nofpv : nofpv + nofpq); % �� dx �ж�ȡ��Ӧ�ı仯��
    Vm(pq) = Vm(pq) + dx(1+ nofpv + nofpq : nofpv + 2 * nofpq);
    
    V = Vm .* exp(1j * Va);% �µĸ���ѹ����
    Vm = abs(V);
    Va = angle(V);
    
    %% ����Ƿ�����
    mis = V .* conj(Ybus * V) - Sbus;
    Fx = [   real(mis([pv; pq]));
        imag(mis(pq))   ];

    if norm(Fx, inf) < tol % ����
        converged = 1;
        fprintf('\nmyNewtonpf''s method power flow (power balance, polar) converged in %d iterations.\n', i);
    end
    
end % end while

if ~converged % ��������δ����
    fprintf('\n myNewtonpf''s method power flow (power balance, polar) did not converge in %d iterations.\n', i);
end
