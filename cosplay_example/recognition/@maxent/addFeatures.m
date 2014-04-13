function C = addFeatures(C,N,L) 
% ADDFEATURES Add new features (weights) to an existing maxent object
%
% C = ADDFEATURES(A,N) Prepends N new features (with zero weights) to
% MaxEnt object A.
%
% C = ADDFEATURES(A,N,L) Adds the new features to the end of the
% feature vector when L==1

% MAXENT.ADDFEATURES  
        
% Jerod Weinman jerod@acm.org
%
% $Id: addFeatures.m 1 2009-05-07 13:41:00Z weinman $
 
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
	

  
% Note: numFeatures is implicitly calculated from W

  if nargin<3 || L~=1
    % Add N zero weights to beginning
	C.weights = [zeros(N,size(C.weights,2)) ; C.weights];
  else
    % Add N zero weights to end, sticking them in between current
    % feature weights and the bias weight
	C.weights = [C.weights(1:end-1,:) ; ...
				 zeros(N,size(C.weights,2)) ; ...
				 C.weights(end,:)];
  end;
