classdef pcanalyzer < preprocessor
%PCANALYZER performs a principal component analysis
%
%   Options:
%   'proportion' : proportion of pc's or number of pc's. If < 1 then
%                 interpreted as a proportion of accounted variance; 
%                 otherwise as an absolute number; if empty 
%                 then all components are used (default = 0.80);
%
%   NOTE:
%   pcanalyzer normalizes the data first by subtracting the mean
%
%   SEE ALSO:
%   princomp.m
%
%   REQUIRES:
%   statistics toolbox
%
%   Copyright (c) 2008, Marcel van Gerven
%
%   $Log: pcanalyzer.m,v $
%

    properties
       
        proportion = []; % proportion of variance accounted for (0.80 is a good starting point)
        
        means; % remove DC component
        
        accvar; % cumulative variance accounted for per component
        pc; % principal components as column vectors
        ev; % eigenvalues of principal components
    end

    methods
    
        function obj = pcanalyzer(varargin)
           
          % check availability
          if ~license('test','statistics_toolbox')
            error('requires Matlab statistics toolbox');
          end

            obj = obj@preprocessor(varargin{:});     
        end
        
        function obj = train(obj,data,design)
                                      
          if iscell(data)

            for c=1:length(data)
              
              x = obj.train(data{c},design{c});
              obj.means{c} = x.means;
              obj.accvar{c} = x.accvar;
              obj.pc{c} = x.pc;
              obj.ev{c} = x.ev;

            end
            
          else

            X = data.collapse();
            
            % ignore nans when taking the mean
            obj.means = mynanmean(X);

            sz = ones(ndims(obj.means)); sz(1) = size(X,1);
            X = X - repmat(obj.means,sz);
            
            [obj.pc,score,obj.ev] = princomp(X);
            
            obj.ev = obj.ev';

            % proportion of the variance that is accounted for
            obj.accvar =obj.ev/sum(obj.ev);

            % determine how many principal components to use
            if ~isempty(obj.proportion)
              
              if obj.proportion >= 1
                prop = 1:obj.proportion;
              else
                prop = 1:find(cumsum(obj.accvar) > obj.proportion,1,'first');
              end
              
              if obj.verbose
                fprintf('selected %d principal components\n',length(prop));
              end
              
              obj.pc = obj.pc(:,prop);
              obj.ev = obj.ev(prop);
              obj.accvar = obj.accvar(prop);
              
            end

          end

        end

        function data = test(obj,data)
     
          if iscell(data)

            for c=1:length(data)

              X = data{c}.collapse();
              sz = ones(ndims(obj.means{c})); sz(1) = size(X,1);
              X = X - repmat(obj.means{c},sz);
              data{c} = dataset((obj.pc{c}' * X')');        
              
            end

          else

            X = data.collapse();
            sz = ones(ndims(obj.means)); sz(1) = size(X,1);
            X = X - repmat(obj.means,sz);            
            data = dataset((obj.pc' * X')');

          end
        end

    end
end
