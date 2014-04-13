function [x,fval,exitflag,output] = lbfgs(fun, x0, options)
% LBFGS Limited memory BFGS optimizer
%
% [x,fval,exitflag,output] = LBFGS(fun, x0, options) finds
% parameter value x that minimizes the value of function handle
% starting from x0. options is a struct that sets parameters of the
% optimization. fval is the final value of the function. exitflag
% indicates the termination condition, and output is a struct with information
% about the optimization.
%
% Valid fields for options struct include:
%
% MaxIter	Maximum number of optimization iterations [1000]
% TolX	Tolerance on the parameter vector [1e-6]
% TolFun	Tolerance on the function value [1e-4]
% TolGrad	Tolerance on gradient L2 norm [1e-4]
% Display	off: 	No display information
%			iter: 	Display information at every iteration
%			final: 	Display information at convergence [default]
% Convex    Indicates whether the function is convex [true]
% MaxStep  Maximum step size L2 norm (for line minimizer) [100]
% SaveFile  File (.mat) in which to save intermediate parameters
% SaveFreq  Frequency (number of iterations) of saves
%
% Values of the exitflag indicate
%
% -3     Function has bad conditions (negative sy or gamma)
% -2     Line minimizer failure (i.e., positive slope)
%  0     Iteration limit exceeded
%  1     Converged on gradient norm
%  2     Cannot step in direction of gradient
%  3     Converged on value function difference

% Translated to Matlab by Jerod Weinman (jerod@acm.org) from a Java
% implementation by Aron Culotta.
%
% A bug in accumulating values was discovered and patched by
% Carl Edward Rasmussen.
%
% Ref:
% Byrd, Nocedal, and Schnabel. Representations of Quasi-Newton
% Matrices and Their Use in Limited Memory Methods. Mathematical
% Programming, 1994
%
% $Id: lbfgs.m 50 2012-05-29 18:47:15Z weinman $
 
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

  if nargin<3
    options = struct;
  end;
  
  if isfield(options,'MaxIter') && ~isempty(options.MaxIter)
    maxIter = options.MaxIter;
  else
    maxIter = 1000;
  end;
  
  if isfield(options,'TolX') && ~isempty(options.TolX)
    xtol = options.TolX;
  else
    xtol = 1e-6;
  end;

  if isfield(options,'TolFun') && ~isempty(options.TolFun)
    ftol = options.TolFun;
  else
    ftol = 1e-4;
  end;
  
  if isfield(options,'TolGrad') && ~isempty(options.TolGrad)
    gtol = options.TolGrad;
  else
    gtol = 1e-4;
  end;
  
  if isfield(options,'Display') && ~isempty(options.Display)
    switch options.Display
      case 'off'
        dspOpt = 0;
      case 'iter'
        dspOpt = 1;
      case 'final'
        dspOpt = 2;
      otherwise
        error('Unknown value for Display option');
    end;
  else
    dspOpt = 2;
  end;

  if isfield(options,'Convex') && ~isempty(options.Convex)
    cnvx = options.Convex;
  else
    cnvx = 1;
  end;
  
  if isfield(options,'SaveFile') && ~isempty(options.SaveFile)
    fname = options.SaveFile;
    sfreq = 1;
  else
    fname = [];
  end;
  
  if isfield(options,'SaveFreq') && ~isempty(options.SaveFreq)
    if isempty(fname)
      error('Must specify SaveFile if SaveFreq is given');
    else
      sfreq = options.SaveFreq;
    end;
  else
    sfreq = 0;
  end;
  
  lineMinOpt = struct;
  if dspOpt==1
    lineMinOpt.Display = 'iter';
  else
    lineMinOpt.Display = 'off';
  end;
  
  lineMinOpt.TolX = xtol;
  
  if isfield(options,'MaxStep') && ~isempty(options.MaxStep)
    lineMinOpt.MaxStep = options.MaxStep;
  end;
 
  m = 4; % 3<m<7 
  

  funcCount = 0;

  ii = 0;

  x = x0;
  
  while (ii<=maxIter)
    
    g = zeros(size(x0)); % gradient
    s = zeros([m length(x0)]); % m previous parameter values
    y = zeros([m length(x0)]); % m previous gradient values
    
    
    [fval,g] = feval(fun,x);

    funcCount = funcCount + 1;

		
    if dspOpt==1 && ii==0
      display(sprintf('L-BFGS initial value = %g',fval));
    end;

    
    alpha = zeros(1,m);
    

    xold = x;
    
    gold = g;
    
    if any(g)
      d = -g/norm(g,2);
    else
      d = -g;
    end;
    
    if norm(g,2)==0 || norm(d,1)==0
      %%%% Small gradient
      msg = 'L-BFGS initial gradient is zero; saying converged';
      exitflag = 1;
      
      output = struct('iterations',{0},...
                      'funcCount',{funcCount},...
                      'algorithm',{'limited-memory BFGS'},...
                      'message',{msg});
      if dspOpt
        display(msg);
      end;
      
      return;
    end;
    
    [step,x,fval,exitflag,output] = linemin(fun, x, d, lineMinOpt);
    
    funcCount = funcCount + output.funcCount;
    
    if (step==0)
      %%%% Could not step
      msg = 'L-BFGS could not step in initial direction';
      
      exitflag = 2;
      
      output = struct('iterations',{0},...
                      'funcCount',{funcCount},...
                      'algorithm',{'limited-memory BFGS'},...
                      'message',{msg});
      if dspOpt
        display(msg);
      end;
      
      return;
      %%%%%%
    end;
    
    [fval,g] = feval(fun,x);
    
    funcCount = funcCount + 1;
    
    if dspOpt==1
      display(sprintf('\t%d\t%g\t%d\t%g',ii,fval,funcCount,norm(g,2)));
    end;
    
    for k=1:(maxIter-ii)
      
      % -Inf - (-Inf) = 0 ; Inf-Inf = 0
      xold(find( isinf(xold) & isinf(x) & x.*xold>0 )) = 0;
      xold = x - xold;
      
      gold(find( isinf(g) & isinf(gold) & g.*gold>0 )) = 0;
      gold = g - gold;
      
      sy = xold*gold';
      yy = gold*gold';
      
      d = g;
      
      gamma = sy/yy; % scaling factor
      
      if (sy<=0)
        if cnvx
          %%%%% Negative sy (which means??)
          msg = 'L-BFGS negative sy';
          exitflag = -3;
          output = struct('iterations',{ii},...
                          'funcCount',{funcCount},...
                          'algorithm',{'limited-memory BFGS'},...
                          'message',{msg});
          if dspOpt
            display(msg);
          end;
          return;
          %%%%%%
        else
          % Function is non-convex. Reset quasi-newton approximations.
          if dspOpt==1
            display('lbfgs\tnegative sy\tresetting');
          end;
          break;
        end;
      end;
      
      if (gamma<0)
        if cnvx
          %%%%% Negative gamma
          msg = 'L-BFGS negative gamma';
          exitflag = -3;
          output = struct('iterations',{ii},...
                          'funcCount',{funcCount},...
                          'algorithm',{'limited-memory BFGS'},...
                          'message',{msg});
          
          if dspOpt
            display(msg);
          end;
          
          return;
          %%%%%%
        else
          % Function is non-convex. Reset quasi-newton approximations.
          if dspOpt==1
            display('lbfgs\tnegative gamma\tresetting');
          end;

          break;
        end;
      end;
      
      if (k==1)
        
        rho = [1/sy];
        s = [xold];
        y = [gold];
        
      elseif (k<=m)
        
        rho = [1/sy rho(1:k-1)];
        s = [xold ; s(1:k-1,:)];
        y = [gold ; y(1:k-1,:)];
        
      else
        
        rho = [1/sy rho(1:end-1)];
        s = [xold ; s(1:end-1,:)];
        y = [gold ; y(1:end-1,:)];
        
      end;
      
      % not sure how to vectorize these two steps
      for n=1:min(k,m) % newest to oldest
        
        alpha(n) = rho(n)*s(n,:)*d';
        d = d - alpha(n)*y(n,:);
      end;
      
      d = d*gamma;
      
      for n=min(k,m):-1:1 % oldest to newest
        beta = rho(n) * y(n,:)*d';
        
        d = d + (alpha(n)-beta)*s(n,:);
      end;
      
      xold = x;
      gold = g;
      
      d = -d;
      
      fvalold = fval;
      
      if dspOpt==1
        display(sprintf('L-BFGS entering linesearch: ||d||=%g, ||x||=%g',...
                        norm(d,2), norm(x)));
      end;
      
      [step,x,fval,exitflag,output] = linemin(fun, x, d, lineMinOpt);
      
      funcCount = funcCount + output.funcCount;
      
      if (step==0)
        %%%% Could not step
        msg = 'L-BFGS could not step in current direction';
        
        exitflag = 2;
        
        output = struct('iterations',{ii},...
                        'funcCount',{funcCount},...
                        'algorithm',{'limited-memory BFGS'},...
                        'message',{msg});
        
        if dspOpt
          display(msg);
        end;
        
        return;
        %%%%%%
      end;
      
      if (exitflag<0)
        %%%% Line minimizer failure
        msg = output.message;
        exitflag = -2;
        output = struct('iterations',{ii},...
                        'funcCount',{funcCount},...
                        'algorithm',{'limited-memory BFGS'},...
                        'message',{msg});
        
        if dspOpt
          display(msg);
        end;
        
        return;
        %%%%%%
      end;
      
      
      [fval,g] = feval(fun,x);
      
      funcCount = funcCount+1;
      
      % Test for terminations
      
      
      if (2*abs(fval-fvalold) <= ftol*(abs(fval)+abs(fvalold)+eps))
        %%%%% Value tolerance convergence
        msg = 'L-BFGS: value difference below tolerance';
        
        exitflag = 3;
        output = struct('iterations',{ii},...
                        'funcCount',{funcCount},...
                        'algorithm',{'limited-memory BFGS'},...
                        'message',{msg});
        
        if dspOpt
          display(msg);
        end;
        return;
        %%%%%%
      end;
      
      if (norm(g,2)<gtol)
        %%%%% Gradient tolerance convergance
        msg = 'L-BFGS: gradient norm below tolerance';
        
        exitflag = 1;
        output = struct('iterations',{ii},...
                        'funcCount',{funcCount},...
                        'algorithm',{'limited-memory BFGS'},...
                        'message',{msg});
        
        if dspOpt
          display(msg);
        end;
        
        return;
        %%%%%%
      end;

      ii = ii+1;
      
      if dspOpt==1
        display(sprintf('lbfgs\t%d\t%g\t%d\t%g',ii,fval,funcCount,norm(g,2)));
      end;
      

      if sfreq && ~mod(ii,sfreq)
        %%% Intermediate save of parameters
        save(fname,'x');
      end;
    end; % Inner-optimization loop	  
	  
    if (ii==maxIter)
      %%%%% Iteration count exceeded
      msg = 'L-BFGS: iteration count exceeded';
      
      exitflag = 0;
      output = struct('iterations',{k},...
                      'funcCount',{funcCount},...
                      'algorithm',{'limited-memory BFGS'},...
                      'message',{msg});
      
      if dspOpt
        display(msg);
      end;
      
      return;
      %%%%%%
    end;

  end; % Outer optimization loop
