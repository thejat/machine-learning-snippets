function U = energy(C,varargin)
% ENERGY Calculate energy of a label for a MaxEnt classifier
%
% U = ENERGY(C,X) Calculates the energy for all labels on a data
% matrix X with feature vectors along the rows using a MaxEnt
% classifier C.
%
% U = ENERGY(C,Y,X) Calculate the energy for a particular vector of
% labels Y on the data matrix X.

% Jerod Weinman
% jerod@acm.org
    
% $Id: energy.m 1 2009-05-07 13:41:00Z weinman $
 
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
  
% MAXENT.ENERGY
  
  if length(varargin)==2
	Y = varargin{1};
	X = varargin{2};
    

    if length(Y)~=size(X,1)
      error('Labels and data instance lengths do not match');
    end;
    
    Y = Y(:); % Make Y a column-vector
    
  elseif length(varargin)==1
	X = varargin{1};
	Y = [];
  else
	error('Incorrect number of arguments');
  end;
  
  % Calculate energy by taking dotproduct over features + the
  % default bias feature
  
  U = X*C.weights(1:end-1,:) + ones(size(X,1),1)*C.weights(end,:);    
	

  % Extract energy values of interest
  if ~isempty(Y)
    ndx = sub2ind(size(U),(1:length(Y))',Y);
    U = U(ndx);
  end;
