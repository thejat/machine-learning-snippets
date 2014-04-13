function [C,fval,exitflag,output] = train(C,Y,X,P,R,S,F,I,options)
% TRAIN Learn the parameters using MAP on training data
%
% [C fval exitflag output] = TRAIN(C,Y,X,P,R,S,F,I,options) 
%
% Input parameters:
%
% [Required]
%
%  C:  Input MaxEnt classifier object. Training starts from the
%      weights of C (unless an improper prior is specified and the
%      weights are all zero).
%  Y:  Vector of training labels with values in 1:C.numLabels
%  X:  Matrix of training data with feature vectors along the rows
%
% [Optional]
%
%  P:  Prior on weights for MAP-based training, which may be one of:
%     - 'none':         No prior, uses Maximum Likelihood training.
%     - 'gauss':        IID Gaussian (L2) [Default]. 
%     - 'laplace':      IID Laplacian (L1). Performs feature
%                       selection according to Williams [2].
%     - 'hypergauss':   Improper scale-free Gaussian prior. See
%                       Buntine and Weigend [1].
%     - 'hyperlaplace': Improper scale-free Laplacian prior. See
%                       Williams [2].
%  R:  A vector of possible regularization values (prior parameters),
%      For 'gauss' it is the standard deviation (default 10) and
%      'laplace' it is the scale parameter alpha (default 0.1).
%  S:  Feature selection. A logical (binary) matrix the same size as 
%      C.weights (use function featureSelection) indicating the
%      weights that should be learned. Use an empty matrix [] as a
%      placeholder to use all weights but specify further
%      parameters.
%  F:  Indicates whether the unselected features are frozen at their
%      current values (F==1) or are given zero values (F==0) [default].
%  I:  Vector containing weights of the instances in the
%      log-likelihood objective. Use an empty matrix [] as a
%      placeholder to equally weight instances but specify further
%      parameters. 
%
%  options: Optimization struct passed directly to the
%           optimizer. See function LBFGS.
%
%
% Outputs:
%
%  C:        The learned MaxEnt classifier object (the same, save for
%            updated weights)
%  fval:     Value of the objective function upon start and termination.
%  exitflag: Exit value of the optimizer. See function lbfgs.
%  output:   Output struct from the optimizer. See function lbfgs.
%
%
% References:
% 
% [1] W. Buntine and A. Weigend. Bayesian back-propagation. Complex
%     Systems, 5:603{643, 1991.
%
% [2] P. M. Williams. Bayesian regularization and pruning using a
%     Laplace prior. Neural Computation, 7:117{143, 1995.
  
  
% MAXENT.TRAIN

% Jerod Weinman jerod@acm.org
%
% $Id: train.m 17 2009-07-28 19:09:58Z weinman $ 
 
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

  
  
% Handle arguments and set defaults
  
  if ~any(size(Y)==1)
	error('Y must be a vector');
  elseif size(Y,1)~=1
	  Y = Y';
  end;
  
  if length(Y) ~= size(X,1)
	error('Labels and data instance lengths do not match');
  end;
  
  if (nargin>=4)

	if strcmpi(P,'hypergauss')
	  P = 4
	elseif strcmpi(P,'hyperlaplace')
	  P = 3;
	elseif strcmpi(P,'gauss')
	  P = 2;
	elseif strcmpi(P,'laplace');
	  P = 1;
	elseif strcmpi(P,'none');
	  P = 0;
	else
	  error(sprintf('Unrecognized regularization method ''%s''',P));
	end;
  else
	P = 2;
  end;
  
  if (nargin<5)
	switch P
	 case {0,3,4}
	  R = 0;
	 case 1
	  R = .1;
	 case 2
	  R = 10;
	end;
  else
	if any(R<0)
	  error('Negative regularization parameter is not permitted');
	end;
	
	
  end;
  
  
  if (nargin<6)
	S = []; % No feature selection specified. Use all features/weights.
  end;

  if nargin<7
	F = 0; % Default behavior: Zero weights unselected.
  end;
  
  if nargin<8 | isempty(I)
	I = []; % No instance weighting specified. Equally weight instances.
  elseif length(I)~=length(Y)
	error('Instance weights length do not match number of instances');
  elseif any(I<0)
	error('Instance weights must be non-negative');
  elseif size(I,1)~=1
	I = I';
  end;
  
  if nargin<9
	options = []; % Use the default optimization parameters
  end;
	

  % Enforce the feature selection "zeroing" behavior
  if ~isempty(S) & ~F
	C.weights = C.weights .* S;
  end;

  if isempty(options)
    
    % Set default optimizer options
    options = struct('Display','iter',...
                     'MaxIter',1000,...
                     'TolFun',1e-4,...
                     'TolGrad',1e-4);
  end;		
    
  % Pass in training data and parameters so the value function can
  % cache them
  value(C.weights,Y,X,P,R,S,F,I,options);
  
  % Get hook to the value function
  F = @value;

  % Vectorize the weights for the optimizer
  Wv = C.weights(:)';
  
  % Initialize weights with random values if necessary. 
  Wv = initweights(Wv,P);

  % Get the initial value
  [V,G] = value(Wv);
  
  if 1 
    % GENERAL OPTIMIZATION METHOD
    
    % Optimize starting at initial weights Wv and the function F = @value
    % L-BFGS is an approximate second-order convex optimization method.
    % The hyper-priors are non-convex, and thus may give L-BFGS problems.

    [Wv,fval,exitflag,output] = lbfgs( F, Wv, options);
    
    % Print results
    if isfield(options,'Display') && strcmp(options.Display,'final')
      fprintf(['train: initial value = %f\tfinal value =' ...
               ' %f\titerations = %d\n'], V, fval, output.iterations);
    end;
    
  else 
    % MATLAB OPTIMIZATION TOOLBOX - FOR DERIVATIVE CHECK
    options = optimset('Display','iter',...
                       'MaxIter',1,...
                       'GradObj','on',...
                       'Hessian','off',...
                       ...%'TolX',1e-10,...
                       'LargeScale','on',...
                       'DerivativeCheck','on');
	  
	
    [Wv,fval,exitflag,output,grad] = fminunc(F, Wv, options);
                       
  end;
  
  % Set the weights we just received from the optimizer
  C.weights(:) = Wv;
  
  fval = [V fval];
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V,G] = value(varargin)
% VALUE Returns the value and the gradient for the objective
%
% VALUE(W,Y,X,P,R,S,F,I,options) to initialize and cache these argument
% from the main function
%
% [V,G] = VALUE(W) Returns the value V and gradient G for the weights W.

  % Cache some varaiables
  persistent Y X P R S F I Gobs Wold Vold Gold dsp;
  
  switch length(varargin) 
   case 1
	W = varargin{1}; % weights VECTOR
   case 9
	
	% Set the values of the persistent variables
	W = varargin{1}; % weights MATRIX
	Y = varargin{2}; % labels
	X = varargin{3}; % data
	P = varargin{4}; % regularization prior
	R = varargin{5}; % regularization prior params
	S = varargin{6}; % feature selection
	F = varargin{7}; % freeze unselected weights
	I = varargin{8}; % instance weights

    options = varargin{9};
    
    if ~isempty(options) && isfield(options,'Display') && ...
          ~isempty(options.Display) && strcmp(options.Display,'iter')
      dsp = 1;
    else
      dsp = 0;
    end;
      
      Gobs = calcObsConstraints(W,Y,X,I);

	Wold = [];

	% And exit
	return;
	
   otherwise
	error('Incorrect arguments');
  end;
    
  % If the weights are the same, return cached values
  if ~isempty(Wold) & max(abs(Wold-W))<5*eps
	V = Vold;
	G = Gold;
	return;
  end;

  % Put the weight vector into the meaningful dimensions
  W = reshape(W, size(Gobs));
  
  
  % Enforce the feature selection
  if ~isempty(S) & ~F
	W = W.* S;
  end;
  
  V = 0;

  % The gradient is the observed energy minus expected energy:
  % G = observation - expectation
	
  G = Gobs;

  % Calculate energy by taking dotproduct over features + the
  % default bias feature
  B = X*W(1:end-1,:) + W(end*ones(size(X,1),1),:);    
  
  % To normalize, find the sum in log space and subtract it.
  mx = max(B,[],2);
  Z = mx + log ( sum(exp(B-mx(:,ones(1,size(B,2)))),2));
  
  B = B-Z(:,ones(1,size(B,2)));

  
  % Find the indices corresponding to the correct labels
  ndx = sub2ind(size(B),1:length(Y), Y);
  
  vv = B(ndx); % logprob of data

  % exp marginals
  B = exp(B);
  


  if isempty(I)
    % No instance weights (all equal, one)
	V = V+sum(vv);
  else
    % Make each instance contribute its value according to I
	V = V + dot(I,vv);
  end;
	
  if any(isinf(vv))
    % Not sure why there would be an infinite value (probability of
    % zero? large weight?), but just in case ..
	warning(sprintf('Infinite value for instance %d\n',find(isinf(vv))));
	
	% Return infinite value, forcing the optimizer to back off. 
	V = Inf;
	
	% Gradient will be meaningless anyway, so use regularization grad.
	[rV,rG] = regValue(G,W,P,R);
	G = - rG(:);
	return; 
    
  elseif any(isnan(vv))
	warning(sprintf('NaN value for instance %d\n',find(isnan(vv))));
	
	% Return NaN value. 
	V = NaN;
	% Gradient will be meaningless anyway, so use regularization grad
	[rV,rG] = regValue(G,W,P,R);
	G = - rG(:);
	
	return;
  elseif any(vv>eps)
	
	a = find(vv>eps); a = a(1);
	
    % Not sure why there would be a positive likelihood, but that's
    % a problem
	warning(sprintf('Positive log likelihood (instance %d) value %f', a,vv(a)));
	
	% Return infinite value. 
	V = Inf;
	
	% Gradient will be meaningless anyway, so use regularization grad
	[rV,rG] = regValue(G,W,P,R);
	G = - rG(:);
	return;
  end;
					  
  
  % G   DxL
  % B   NxL
  % X   NxD

  % we don't want to have to transpose X, because it's probably BIG
  
  B = B'; % now LxN

  if isempty(I)
    % Unit weight on each instance for gradient contribution
	G = G - [(B*X)' ; sum(B,2)'];
  else

	B = double(B);
	
    % Make instance weights the diagonal of a matrix between the
    % marginals and the data 
	sdI = spdiags(I',0,length(I),length(I));

	% A workaround for single datatypes, but allowing binary instance weights 
	% (logical*single is ok, but matlab dislikes sparse*single)
	if islogical(I)
	  sdI = logical(sdI);
	end;
	
  BI = full(B*sdI); 
  
	G = G - [(BI*X)' ; sum(BI,2)'];
  end;
  
  
  % Calculate regularization value and gradient
  [rV,rG,rS] = regValue(G,W,P,R);

  % Uncomment if you want to keep tabs on the L1 feature selection
  
  %if P==1 && ~allv(rS) % Laplacian
  %  fprintf('trimmed %d weights\n',sumv(~rS));
  %end;

  if dsp
    fprintf('Value:\t%f\t%f\n',-V,-rV);
  end;
  
  % Add the regularization value and gradient
  V = V + rV;
  G = G + rG;
  
  % Enforce any Laplacian feature selection: make the corresponding
  % gradients zero
  G = G.*rS;
  
  
  if ~isempty(S)
    % Enforce input feature selection
    G = G .* S;
  end;
  
  % Vectorize gradient
  G = - G(:)'; % Switch signs since the optimization toolbox 
  V = -V;      % does minimization
  

  % Cache values
  Wold = W(:)';
  Vold = V;
  Gold = G;
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V,G,S] = regValue(G,W,P,R)
% REGVALUE Regularization value and gradient
  
  
  % Resulting feature selection
  S = ones(size(G));
  
  % Regularization
  switch P
   case 0
	% None
	V = 0;
	G = zeros(size(G)); 
   case 1
	% Laplacian
	V = - sumv(abs(W).*R);
    % Feature selection criterion. See Williams [2].
	S =   W~=0 | abs(G)>R; 
	G = - sign(W).*R;

   case 2
	% Gaussian
	V = - sumv( (W.^2)./(2*R.^2) );
	G = - W./(R.^2);
   case 3
	% Hyper-Laplacian
	
	N = sum(abs(W(:)));
	
	V = - numel(W)*log(N);

    % Feature selection criterion. See Williams [2].
	S =   W~=0 | abs(G) > numel(W)/N;
	
    G = - sign(W) * numel(W)/N;

   case 4
	% Hyper-Gaussian
	
	N = sum(W(:).^2);
	
	V = - numel(W) * log(N/2);
	G = - W * 2*numel(W)/N ;
	
   otherwise
	error('Unknown regularization');
  end;

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function F = calcObsConstraints(W,Y,X,I);
% Calculates observation portion of the gradient
  
  L = size(W,2); % Number of class labels
  
  % Make a probability matrix with 1s at the given labels
  if isa(X,'single')
      % Matlab doesn't want sparse*single, so we must make a full
      % logical matrix
      B = false(L,length(Y)); % LxN logical
  
      ndx = sub2ind(size(B), Y, 1:length(Y));
  
      B(ndx) = 1;
  else
      B = sparse(Y,1:length(Y),1,L,length(Y));
  end;
  
  % X NxD
  
  if isempty(I)
	F = [(B*X)' ; sum(B,2)'];
  else
	sdI = spdiags(I',0,length(I),length(I));
	
	% A workaround for single datatypes, but allowing binary instance weights 
	% (logical*single is ok, but matlab dislikes sparse*single)
	if islogical(I)
	  sdI = logical(sdI); 
	end;
	
  BI = B*sdI;
	F = [(BI*X)' ; sum(BI,2)'];
  end;
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function W = initweights(W,P) 
% Scale-free priors are improper (infinite at 0), and thus 
% require initialization if the appropriate norm is small enough.
  
  if P==4 && sum(W.^2)<eps
    % Initialize scale-free Gaussian by sampling from a Gaussian
	A = 1/sqrt(length(W));
	W = A*randn(size(W));
  elseif P==3 && sum(abs(W))<eps
    % Initialize scale-free Laplacian with A*log(R) where R is
    % uniform [0,1] and A determines the scale. The value for A
    % comes from Williams [2].
    
	A = 1/sqrt(2*length(W));
    W = (A*log(rand(size(W)))).*((-1).^randint(2,size(W)));
  end;
  
