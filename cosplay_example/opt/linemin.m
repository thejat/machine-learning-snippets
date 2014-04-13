function [alam,x,fval,exitflag,output] = linemin(fun, x0, d,options)
% LINEMIN Line minimizer
%
% [alam,x,fval,exitflag,output] = linemin(fun, x0, d,options)
%
% alam is the scalar (less than or equal to 1) amount stepped in
% direction d for x to get the resulting value fval. exitflag
% indicates the termination condition, and output is a struct with
% information about the optimization.
%
% Valid fields for options struct include:
%
% MaxIter	Maximum number of optimization iterations
% TolX	Tolerance on x
% Display	
%     off: 	No display information
%			iter: 	Display information at every iteration [default]
%
% Values of the exitflag indicate
%
%  -2     Internal error
%  -1     Slope is positive
%   0     Iteration count exceed
%   1     Sufficient decrease (normal termination)
%   2     Jump required is too small (alam returned is 0)

% Written by Jerod Weinman (jerod@acm.org)
%
% Ref:
% See Numerical Recipes in C, p.385. lnsrch. A simple backtracking line
% search. No attempt at accurately finding the true minimum is
% made. The goal is only to ensure that linemin will return a
% position of lower value.
  
% $Id: linemin.m 47 2012-05-03 12:33:54Z weinman $
 
% Jerod Weinman
% jerod@acm.org
% Copyright 2006, 2008, 2011
 
%    This file is part of Matlab LBFGS.
%
%    Matlab LBFGS is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    Matlab LBFGS is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with Matlab LBFGS.  If not, see <http://www.gnu.org/licenses/>.
  

  if nargin<4
    options = struct;
  end;
  
  if isfield(options,'MaxIter') & ~isempty(options.MaxIter)
    maxIter = options.MaxIter;
  else
    maxIter = 100;
  end;
  
  if isfield(options,'MaxStep') & ~isempty(options.MaxStep)
    stpmax = options.MaxStep;
  else
    stpmax = 100;
  end;
  
  if isfield(options,'TolX') & ~isempty(options.TolX)
    tolx = options.TolX;
  else
    tolx = 1e-6;
  end;

  if isfield(options,'Display') & ~isempty(options.Display)
    switch options.Display
      case 'off'
        dspOpt = 0;
      case 'iter'
        dspOpt = 1;
      otherwise
        error('Unknown value for Display option');
    end;
  else
    dspOpt = 1;
  end;
  
  
  alf = 1e-4; % Ensures sufficient decrease in function value.
  
  stpmod = 1;
  
  alam2 = 0;
  tmplam = 0;

  x = x0;

  
  [fval,g] = feval(fun,x);
  
  fold = fval;
  f2 = fold;

  funcCount = 1;
  
  if (norm(d,2)>stpmax)
    if dspOpt
      display('linemin: step too big: scaling direction');
    end;
    
    stpmod = stpmax/norm(d,2);
    d = d*stpmod;
  end;
  
  slope = g*d';
  

  if (slope>0)
    %%%%% Bad Slope 
    alam = 0;
    x = x0;
    fval = fold;
    msg = 'Line min: Slope is positive';
    exitflag = -1;

    output = struct('iterations',{0},...
                    'funcCount',{funcCount},...
                    'algorithm',{'backtrack line minimization'},...
                    'message',{msg});
    if dspOpt
      display(msg);
    end;
    return;
    %%%%%
  end;

  alamin = tolx/max(abs(d)./max(abs(x),1));
  alam = 1;
  oldalam = 0;
  
  for k=1:maxIter
    
    x = x + d*(alam-oldalam);
    
    oldalam = alam;
    
    if (alam<alamin)
      %%%% Small jump
      alam = 0;
      x = x0;
      fval = fold;
      msg = 'Line min: Jump too small';
      exitflag = 2;
      
      output = struct('iterations',{k},...
                      'funcCount',{funcCount},...
                      'algorithm',{'backtrack line minimization'},...
                      'message',{msg});
      if dspOpt
        display(msg);
      end;
      return;
      %%%%%%
    end;

    funcCount= funcCount + 1;
    fval = feval(fun,x);

    if (fval <= fold + alf*alam*slope) 
      %%%% Wolfe condition

      alam = alam*stpmod;
      
      msg = 'Line min terminated: sufficient decrease';
      exitflag = 1;
      
      output = struct('iterations',{k},...
                      'funcCount',{funcCount},...
                      'algorithm',{'backtrack line minimization'},...
                      'message',{msg});
      
      if dspOpt
        display(msg);
      end;
      
      return;
      %%%%%
    elseif isinf(fval) | isinf(f2)
      
      if dspOpt
        display('Line min: Inf value. Scaling step size.');
      end;
      
      tmplam = .1* alam;
      
    else % Backtrack
      if alam==1 % first time through
        tmplam = -slope/(2*(fval-fold-slope));
      else
        rhs1 = fval-fold-alam*slope;
        rhs2 = f2-fold-alam2*slope;
        
        if (alam==alam2)
          msg = 'Failure: dividing by alam-alam2=0';
          exitflag = -2;
          
          output = struct('iterations',{k},...
                          'funcCount',{funcCount},...
                          'algorithm',{'backtrack line minimization'},...
                          'message',{msg});
          
          if dspOpt
            display(msg);
          end;
          return;
        end;
        
        a = (rhs1/(alam*alam)-rhs2/(alam2*alam2))/(alam-alam2);
        b = (-alam2*rhs1/(alam*alam)+alam*rhs2/(alam2*alam2))/(alam-alam2);

        if (a == 0.0) 
          tmplam = -slope/(2.0*b);
        else
          disc = b*b-3.0*a*slope;
          if (disc < 0.0)
            tmplam = .5 * alam;
          elseif (b <= 0.0)
            tmplam = (-b+sqrt(disc))/(3.0*a);
          else 
            tmplam = -slope/(b+sqrt(disc));
          end;
        end;

        if (tmplam > .5*alam)
          tmplam = .5*alam;    % lambda <= .5 lambda_1
        end;
      end;
    end;
    
    alam2 = alam;
    f2 = fval;

    if dspOpt
      display(sprintf('linemin\t%d\t%g\t%g\t%g',k,fval,alam,alamin));
    end;
    
    alam = max(tmplam, .1*alam);
    

  end;
  
  
  alam = 0;
  x = x0;
  fval = fold;
  msg = 'Line min: Too many iterations';
  exitflag = 0;
  output = struct('iterations',{k},...
                  'funcCount',{funcCount},...
                  'algorithm',{'backtrack line minimization'},...
                  'message',{msg});
  if dspOpt
    display(msg);
  end;
