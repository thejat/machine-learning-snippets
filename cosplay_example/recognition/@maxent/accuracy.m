function A = accuracy(C,Y,X,I)
% ACCURACY Measure accuracy of a MaxEnt classifier on a data set
%
%  A = ACCURACY(C,Y,X) where C is a MaxEnt object, Y is the list of
%  correct labels, and X is the matrix of feature vectors. A is the
%  fraction of correct predictions of C on X.
%
%  A = ACCURACY(C,Y,X,I) where I is a logical vector indicating
%  which training instances should be included in the measure.
%
% Elements of Y must be in 1:C.numLabels and feature vectors of X
% are along the rows.

% MAXENT.ACCURACY
    
% Jerod Weinman jerod@acm.org
%
% $Id: accuracy.m 1 2009-05-07 13:41:00Z weinman $
 
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
 

  Y = Y(:); % Make column vector
  
  P = map(C,X); % Predictions of the model on X
  
  % Fraction of correct predictions
  if nargin<4 || isempty(I)
    A = sum(P==Y)/length(Y); 
  else
    A = sum(P(I) == Y(I)) / sum(I);
  end;
