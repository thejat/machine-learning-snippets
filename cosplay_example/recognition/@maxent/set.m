function C = set(C,F,V)
% SET Set some attributes of a MaxEnt classifier object  
%
% C = SET(C,F,V) where F is the attribute and V is value. Supported
% field/value pairs: 
%
%  'weights': A matrix of proper size
  
% Jerod Weinman jerod@acm.org
%
% $Id: set.m 1 2009-05-07 13:41:00Z weinman $
 
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
  
  switch F
   case 'weights'
	if any(size(V)~=size(C.weights))
	  error('weights must be a matrix of the proper sizes');
	else
	  C.weights = V;
	end;
   otherwise
	error(sprintf('Unknown field ''%s''',F));
  end;
  
