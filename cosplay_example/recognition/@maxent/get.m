function V = get(C,F)
% GET Accessor for MaxEnt classifier object
%
% Field options:
%  numLabels:   Number of output labels/classes 
%  weights:     Weight parameters of the classifier
%  numFeatures: Number of features (excluding bias feature)
  
% Jerod Weinman
% jerod@acm.org
    
% $Id: get.m 1 2009-05-07 13:41:00Z weinman $
 
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
  
% MAXENT.GET
	
  switch F
   case 'numLabels'
	V = C.numLabels;
   case 'weights'
	V = C.weights;
   case 'numFeatures'
	V = size(C.weights,1)-1;	
   otherwise
	error(sprintf('Unknown field ''%s''',F));
  end;
  
  
