clc;clear all;close all;

%% Example 1
fprintf('SOCP Example using CVX:\n');
%   Minimize
%    obj: x1 + x2 + x3 + x4 + x5 + x6
%   Subject To
%    c1: x1 + x2      + x5      = 8
%    c2:           x3 + x5 + x6 = 10
%    q1: [ -x1^2 + x2^2 + x3^2 ] <= 0
%    q2: [ -x4^2 + x5^2 ] <= 0

n = 6;
A = [1 1 0 0 1 0; ...
    0 0 1 0 1 1];
b = [8;10];
c = ones(n,1);
cvx_begin quiet
   variable x(n)
   dual variables y z1 z2
   minimize( c' * x)
   subject to
      y : A * x == b;
      z1 : norm(x(2:3),2) <= x(1);
      z2 : norm(x(5),2) <= x(4);
cvx_end
disp(['  Primal opt:' num2str(cvx_optval)])
fprintf('  Optimal solution: \n');
disp(x)
% Output: 
%    18.0000
% 
%     9.3340
%    -2.0246
%          0
%     0.6906
%     0.6906
%     9.3094

%% Example 2: Duality
fprintf('Duality Example:\n');
%   Maximize Primal
%    obj: x1 + x2 + x3 + x4 + x5
%   Subject To
%    c1: x1 + x2      + x5      = 8
%    c2:           x3 + x5 = 10
%    q1: [ x1^2 + x2^2 + x3^2 + x4^2 - x5^5] <= 0

n = 5;
H = [1 1 0 0 1; ...
    0 0 1 0 1];
h = [8;10];
f = ones(n,1);
cvx_begin quiet
   variable x(n)
   dual variables y1 y2
   maximize( f' * x)
   subject to
      y1 : H * x == h;
      y2 : norm(x(1:n-1),2) <= x(n);
cvx_end
disp(['  Primal opt:' num2str(cvx_optval)]) %Primal Optimal
% disp(x)

%   Minimize Dual
%    obj: h'v
%   Subject To
%    c1: -H'v + [z;w] = -f      
%    q1: [ z ] <= w

At = [eye(n-1);zeros(1,n-1)];
c  = [zeros(n-1,1);1];
cvx_begin quiet
   variables v(2) z(n-1) w
   dual variables yt1 yt2
   minimize(h' * v)
   subject to
      yt1 : -H' * v +  At * z + c*w == -f;
      yt2 : norm(z,2) <= w;
cvx_end
disp(['  Dual opt:' num2str(cvx_optval)]) %Dual Optimal