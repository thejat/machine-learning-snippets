function [C,V,Cv,fval,exitflag,output] = cvtrain(C,Y,X,P,R,S,F,I,It,Iv,E,options)
% CVTRAIN Cross-validation training for a MaxEnt classifier
%
% [C,V,Cv,fval,exitflag,output] = CVTRAIN(C,Y,X,P,R,S,F,I,It,Iv,E,options) 
%
% Input parameters:
% [Required]
%  C:  Input MaxEnt classifier object
%  Y:  Vector of training labels with values in 1:C.numLabels
%  X:  Matrix of training data with feature vectors along the rows
%  P:  Prior on weights for MAP-based training, which may be one of:
%     - 'gauss':        IID Gaussian (L2). 
%     - 'laplace':      IID Laplacian (L1). Performs
%                      feature selection according to [1].
%  R:  A vector of possible regularization values (prior parameters)
% [Optional]
%  S:  Feature selection. A logical (binary) matrix the same size as 
%      C.weights (use function featureSelection) indicating the
%      weights that should be learned. Use an empty matrix [] as a
%      placeholder to use all weights but specify further
%      parameters.
%  F:  Indicates whether the selected features are frozen at their
%      current values (F==1) or are given zero values (F==0).
%  I:  Vector containing weights of the instances in the
%      log-likelihood objective. Use an empty matrix [] as a
%      placeholder to equally weight instances but specify further
%      parameters. 
%  It: Logical (binary) vector indicating the training set during
%      the cross-validation stage.
%  Iv: Logical (binary) vector indicating the validation set during
%      the cross-validation stage.
%  E:  Evaluation function handle with usage E(C,Y,X,I). 
%
%  options: Optimization options passed directly to the
%           optimizer. See function lbfgs.
%
% If no training instances (It) are specified, the first half of
% the instances are used. If no validation instances (Iv) are
% specified, the logical complement of the training instances (~It)
% are used. If no evaluation function is specified, the
% log-likelihood is used.
%
% See also TRAIN, LOGPROB, FEATURESELECTION.
  
% Jerod Weinman jerod@acm.org
%
% $Id: cvtrain.m 1 2009-05-07 13:41:00Z weinman $
 
% Jerod Weinman
% jerod@acm.org
% Copyright 2005, 2006, 2008, 2009
 
%    This file is part of Matlab MaxEnt.
%
%    Matlab MaxEnt is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    Matlab MaxEnt is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with Matlab MaxEnt.  If not, see <http://www.gnu.org/licenses/>.
  
%% Process parameters
  
  if nargin<3
    error('Requires at least three parameters');
  end;
  
  if ~any(size(Y)==1)
	error('Y must be a vector');
  elseif size(Y,1)~=1
	Y = Y';
  end;
  

  if length(Y) ~= size(X,1)
	error('Labels and data size do not match');
  end;
  
  if (nargin>=4)
	switch P
     case {'gauss','laplace'}
      0;
	 case {'none','hyperlaplace','hypergauss'}
	  error('No regularization to do. Use maxent.train.');
	 otherwise
	  error(sprintf('Unrecognized regularization method ''%s''',P));
	end;
  else
	error('Regularization method required.');
  end;
  
  if (nargin<5)
	error('Regularization values required.');
  elseif any(R<0)
	error('Negative regularization parameter is not permitted');
  end;
  
  
  if (nargin<6)
	S = []; % No feature selection specified. Use all features/weights.
  end;
  
  if nargin<7
	F = 0; % Default behavior: Zero weights unselected.
  end;
  
  if nargin<8 | isempty(I)
	I = []; % No instance weighting specified. Equally weight instances.
  elseif length(I)~=length(X)
	error('Instance weights length do not match number of instances');
  elseif any(I<0)
	error('Instance weights must be positive');
  elseif size(I,1)~=1
	I = I';
  end;

  if nargin<9 | isempty(It)
    It = false(size(Y));
    It(1:floor(length(Y)/2)) = 1; % Use the first half
  elseif length(It)~=length(Y)
	error('Training set indicator length does not match number of instances');
  elseif ~islogical(It)
	error('Training set indicator must be logical');
  end;
  
  if size(It,1)~=1
	It = It';
  end;
  
  if nargin<10 | isempty(Iv)
	Iv = ~It; % Use the complement of the training instances
  elseif length(Iv)~=length(Y)
	error('Validation set indicator length does not match number of instances');
  elseif ~islogical(Iv)
	error('Validation indicator must be logical');
  end;
  
  if size(Iv,1)~=1
	Iv = Iv';
  end;
  
  if any(It&Iv)
    warning('Training and validation instances overlap.');
  end;
  
  if nargin<11
	E = []; % Use the default validation function (log likelihood)
  end;
  
  if nargin<12
	options = []; % Use the default optimization parameters
  end;
  
  
  
  C0 = C; % Classifier to start training with
  
  if isempty(I)
    % Equally weight (with ones) the training instances
	Iw = double(It);
  else
    % Use the weights only at the training instances -- all others
    % are zero and thus excluded.
	Iw = I.*double(It);
  end;

  for r=1:length(R)
	Cv(r) = train(C0,Y,X,P,R(r),S,F,Iw,options);
	C0 = Cv(r);

	if isempty(E)
	  V(r) = dot( logprob(C0,Y,X), Iv); % Log likelihood
	else
	  V(r) = feval(E,C0,Y,X,Iv);
	end;
	
  end;
  
  % Find the largest value of the evaluation function on the
  % training set
  rx = argmax(V);
  
  % Train with all instances (subject to instance weighting I)
  % using the optimal parameter value. Begin with the classifier
  % learned on the training data at the optimal parameter value.
  C = train(Cv(rx),Y,X,P,R(rx),S,F,I,options);
  
	
