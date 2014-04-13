function A = argmax(X,D)
%    ARGMAX Return the indices of maximum elements of an array
%
% A = ARGMAX(X) returns the indices of the largest elements along
% different dimensions of an array. 
%
% If X is a vector, it returns the index of the largest element.
%
% If X is an array, it returns the indices of the largest element
% in each column in a row vector.
%
% If X is a multidimensional array, it treats the values along the
% first non-singleton dimension as vectors, returning the index of
% the  maximum value of each vector.
%
% A = ARGMAX(X,D) returns the indices of the largest elements along
% dimension D.
%
% Returns the index of the first element found in case of ties.

  
% Jerod Weinman 
% jerod@acm.org
% (c) 2008

% $Id: argmax.m 1 2009-05-07 13:41:00Z weinman $
 
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
  
  
  if nargin==1 & ndims(X)==2 & any(size(X)==1) % vector
	[M, A] = max(X);
  else
	if nargin==1
	  D = min(find(size(X)~=1)); % first non-singleton dimension
	elseif D<1 | D>ndims(X)
      error('Invalid dimension %d',D);
	end;
    
	[M,A] = max(X,[],D);
    
  end;
