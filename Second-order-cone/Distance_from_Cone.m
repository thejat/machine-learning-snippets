clc;clear all;close all;


%% Distance of a point to SOC
fprintf('Distance of a point to SOC:\n');
%   Maximize Primal
%    obj: (a + Bx)'(a+Bx)
%   Subject To
%    q1: [ x1^2 + x2^2 + x3^2 + x4^2 - x5^5] <= 0

n = 5;
a = randn(n,1);
%a = zeros(n,1);
B = randn(n); B = sqrtm(B'*B);
cvx_begin quiet
   variable x(n)
   dual variables y
   minimize( (a + B * x)'*(a + B * x))
   subject to
      y : norm(x(1:n-1),2) <= x(n);
cvx_end
disp(['  Primal opt:' num2str(cvx_optval)]) %Primal Optimal
disp(x)