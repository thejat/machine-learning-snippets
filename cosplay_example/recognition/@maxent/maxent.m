function C = maxent(varargin)
% MAXENT  MaxEnt constructor
%
% C = MAXENT(L,M) where L is the number of labels, M is the number
% of features
%
% C = MAXENT Creates an empty/default object
% C = MAXENT(A) where A is a MaxEnt object will return a copy of A
  
% Jerod Weinman jerod@acm.org
%
% $Id: maxent.m 1 2009-05-07 13:41:00Z weinman $ 
 
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

  
% Object fields:
%   numLabels
%   weights
  
  if nargin == 0
	
	% Set default fields
	C.numLabels = 0;
	C.weights = [];
	
	C = class(C,'maxent');
  elseif nargin == 1 & isa(varargin{1},'maxent')
	% Copy argument
    
	C = varargin{1};
	
  else

	L = varargin{1}; % Number of labels
	M = varargin{2}; % Dimension of feature vector
	
    % Initialize weights -- there is an additional index for the
    % bias feature (a const feature that is appended to every
    % feature vector so that the decision isn't restricted to
    % passing through the origin
    
	W = zeros(M+1,L);

	% Set fields
	C.numLabels = L;
	C.weights = W;
	
	C = class(C,'maxent');
  end;
