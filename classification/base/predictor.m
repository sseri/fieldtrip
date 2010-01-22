classdef predictor < clfmethod
%PREDICTOR base class for classifier and regressor
% 
% NOTE:
% optimizer can also act as a predictor but is not of this class
%
% Copyright (c) 2009, Marcel van Gerven
%
% $Log: predictor.m,v $
%    
    
  methods(Abstract)
    p = predict(obj,data);
  end
  
end
