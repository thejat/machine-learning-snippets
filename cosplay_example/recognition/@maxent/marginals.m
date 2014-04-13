function B = marginals(C,X,G)
% MARGINALS Calculate probabilities of data 
%
% B = MARGINALS(C,X) where X is a data matrix, with feature vectors
% along the rows. B contains the corresponding probabilities with
% labels along the rows.
%
% B = MARGINALS(C,X,G) where G indicates whether to exponentiate
% the probabilities (G==1) or return them in logspace (G==0).
  
% Jerod Weinman jerod@acm.org
%
% $Id: marginals.m 1 2009-05-07 13:41:00Z weinman $
 
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
  
  if nargin<3
	G = 1;
  end;
  
  % MAXENT.MARGINALS
	
  % Calculate energy
  B = energy(C,X);
	
  % To normalize, find the sum in log space and subtract it.
  mx = max(B,[],2);
  Z = mx + log ( sum(exp(B-mx(:,ones(1,size(B,2)))),2));
  
  B = B-Z(:,ones(1,C.numLabels));
  
  if G
	B = exp(B);
  end;
