function example

% Test example of L-BFGS
tlbfgs

% Test example of the backtracking line minimizer, which is called
% from within lbfgs, but you could call it separately if desired.
tlinemin

function tlbfgs
  
  % Create a handle to a paraboloid function
  fun = @paraboloid;

  % Call L-BFGS starting from the origin
  [x,fval,exitflag,output] = lbfgs(fun, zeros(1,14))

% N-dimensional paraboloid
function [v,g] = paraboloid(x)
  
  A = [1 10 3 5 7 9 1 1 2 3 5 8 13 21]; % coefs
  B = [0 5 3 8 11 19 30 49 79 128 3 5 7 9];  % center
  v = sum(A.*((x-B).^2));
  g = 2*A.*(x-B);
  
  
function tlinemin
 
  % Create a handle to a paraboloid function
  fun = @parabola;
 
  % Search for the minimimum of the paraboloid from the point (1,1)
  % in the direction (-5,-10)
  
  [alam,x,fval,exitflag,output] = linemin(fun, [1 1], -[5 10])
  
  
% N-dimensional parabola at the origin
function [v,g] = parabola(x)
  
  v = sum(x.^2);
  g = 2*x;
