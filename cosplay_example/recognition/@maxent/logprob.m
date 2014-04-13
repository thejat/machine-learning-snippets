function L = logprob(C,Y,X)
% LOGPROB Log probability of data
%
% L = LOGPROB(C,Y,X) where Y is a vector of labels in 1:C.numLabels
% and X is a data matrix with feature vectors along the rows. L is
% a vector containing the log probabilities.

% Jerod Weinman jerod@acm.org
%
% $Id: logprob.m 1 2009-05-07 13:41:00Z weinman $
 
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
  
% MAXENT.LOGPROB

  if size(Y,2)~=1
    Y = Y';
  end;
  
  if size(X,1)~=length(Y)
    error('Labels and data instance lengths do not match');
  end;
  
  % Calculate all the un-normalized energies
  U = energy(C,X);
	
  % Normalization constant
  Z = logsumexp(U,2);
  
  % Find the indices corresponding to the correct labels
  ndx = sub2ind(size(U),(1:length(Y))', Y);
  
  U = U(ndx); % energy of labels
  
  % Normalize
  L = U - Z;
  
  
