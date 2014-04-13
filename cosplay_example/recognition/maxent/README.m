% This Maximum Entropy classifier package was written by Jerod
% Weinman (jerod@acm.org). You are free to use it for personal or
% academic use. If you publish research that relies on this
% software, please kindly acknowledge it.
%
% One canonical paper you may read to understand the model the code
% is built upon is:
%
% Adam L. Berger, Stephen A. Della Pietra, and Vincent J. Della
% Pietra. A maximum entropy approach to natural language
% processing. Computational Linguistics, 22(1):39--71, 1996.
%
%
% The code works with both real-valued and binary data/feature
% vectors. Note that if you have binary data, making the data
% matrix sparse will drastically decrease training time (orders of
% magnitude, depending on the sparsity).
%
% Here are a few examples of how to train and use a classifier.

%%
%% Create some training data
%%

% Labels are between 1 and 3 for a three class problem.
Y = floor(rand(100,1)*3)+1;

% Corresponding feature vectors have dimension 9, and are arranged
% along the rows of a data matrix.
X = randn(100,9);


%%
%% Create a new classifier 
%%

% The object will have with 3 classes and 9 features. Note that
% by default, a "bias" feature is used -- this feature has a
% constant value (i.e., 1) appended to every feature vector and
% multiplied by a corresponding weight for each class, just like
% every other feature.

C0 = maxent(3,9);


%%
%% Train
%%

% There are several regularizing priors available for MAP-based
% training (see the train function for more details).

% Maximum-likelihood 
C1 = train(C0,Y,X,'none');

% Gaussian with a standard deviation on the weights of 10
C1 = train(C0,Y,X,'gauss',10);

% Laplacian with "scale" = a = 3 (standard deviation is sqrt(2)/a.
C1 = train(C0,Y,X,'laplace',3);

% Laplacian training does weight pruning (see the train function
% for a reference and more details).

% See how many weights were pruned
sum(sum(get(C1,'weights')==0))


% Since each weight is a feature paired with a class, we can see
% which features are entirely eliminated from the model by checking
% to see that the weight on a feature for each class is pruned
find( all(get(C1,'weights'),2) )


% If you want to use cross-validation to choose the parameters for
% the priors, you can do this with the following. By default,
% cvtrain uses the first half of the data for "pre-training" and the
% second half for validation. All the data is used to train with
% the best parameter. For the vector of options to the scale
% parameter, they should be placed in order of decreasing
% regularization, since training iterates through the options and
% continues from the previous model.

% By default, likelihood is used as the evaluation function
[C1,V] = cvtrain(C0,Y,X,'gauss',10.^(linspace(-4,4,20)));

% You can check the validation parameter values by examining V.  You
% can also pass in your own function to be used for evaluation; it
% requires a certain signature (see the cvtrain documentation). The
% function accuracy qualifies.
[C1,V] = cvtrain(C0,Y,X,'gauss',10.^(linspace(-4,4,20)), ...
                 [],0,[],[],[],@accuracy);

% Other priors require no scale parameters, though they are
% improper (infinite at the weight zero vector and thus cannot be
% normalized). When these are used, the training function
% automatically initializes the weights to (hopefully) reach a
% local optimum and avoid this meaningless solution.

% One is based on integrating (marginalizing) the standard
% deviation from the Gaussian. Since the optimizer is convex and
% this prior is non-convex, the results are somewhat unpredictable.
C1 = train(C0,Y,X,'hypergauss');

% If you don't want to do cross-validation to choose the scale, you
% could try training using a rough approximate scale to initialize the
% parameters and then continue training with the scale-free prior:

C1 = train(C0,Y,X,'gauss',10);
C1 = train(C1,Y,X,'hypergauss');

% Another scale-free prior is based on marginalizing the
% scale-parameter from the Laplacian. Like the regular Laplacian, this
% prior also does weight pruning

C1 = train(C0,Y,X,'laplace',3);
C1 = train(C1,Y,X,'hyperlaplace');



%%
%% Evaluation
%%

% There are a few simple evaluation methods provided.

% You may get the log probability of each member of the dataset,
% and get the total probability by summing them

L = sum(logprob(C1,Y,X))

% Accuracy fraction
A = accuracy(C1,Y,X)

% You may also get the probability vector for a data matrix (These are
% called marginals to correspond to these probabilities in joint
% models like CRFs).
B = marginals(C1,X);

% If you want these in logspace (un-exponentiated), pass a flag:
B = marginals(C1,X,0);


% For a single instance:

B = marginals(C1,X(1,:))
B = marginals(C1,X(1,:),0)

% Or you can simply look at the most likely labels yourself
P = map(C1,X);

%%
%% Feature Selection
%%

% You can do more interesting things with training, like exclude
% certain features from use 

% Get a feature selection template matrix for the classifier
% (by default all features are excluded
S = featureSelection(C0);

% It is an M+1 x L matrix, where M is the number of features and L the
% number of classes/labels.
size(S)         

% Completely exclude features 2 and 5 for all 3 classes
S(:) = 1;
S([2 5],:) = 0


% Train using that feature selection
C1 = train(C0,Y,X,'gauss',10,S);

% Look at the weights, they have zeros in the appropriate rows/features.
W = get(C1,'weights')
                
                
% You can also fix weights at non-zero values.
% Using the previous feature selection, we'll clamp those weights
% at their ML estimate:
C1 = train(C0,Y,X,'none');

W = get(C1,'weights');
W([1 4],:) % these will change
W([2 5],:) % these should stay the same

C1 = train(C1,Y,X,'gauss',10,S,1)

W = get(C1,'weights');
W([1 4],:) % these will change
W([2 5],:) % these should stay the same
 

%%
%% Instance weighting
%%

% If you want to re-weight the contribution of each training instance
% in the likelihood function (effectively modifying the so-called
% "empirical distribution") you can use a weight vector the same size
% as the labels.

% Count any instances of class 3 twice as much as the others
I = ones(size(Y));
I(Y==3) = 2;

% Note that empty matrices can be passed for any non-scalar data to
% use defaults, and 0 can be passed for almost any scalar data.
C1 = train(C0,Y,X,'gauss',10,[],0,I);


