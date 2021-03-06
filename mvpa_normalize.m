function [Xnorm, param] =  mvpa_normalize(X, method, param)
% mvpa_normalize() - normalize features for MVPA analysis
%
% Usage:  [X, param] = mvpa_normalize(X,'scale')
%
% Input:
% - X      = matrix of features to normalize (trials*features)
% - method = 'scale' or 'zscore' (from my experience, scale works better)
%
% Outputs:
% - Xnorm = normalized matrix (trials*features)
% - param = parameters used for the normalization (to use later on test set)
%
% Author: seb.crouzet@gmail.com

if exist('param','var') == 0 % param is not an input, this is usually the training set
    
    param{1} = method;
    
    if strcmp(method,'zscore')
        
        mu     = mean(X,1);
        sigma = std(X,[],1);
        
        sigma0 = sigma;
        sigma0(sigma0==0) = 1;
        Xnorm = bsxfun(@minus, X, mu);
        Xnorm = bsxfun(@rdivide, Xnorm, sigma0);
%        Xnorm = (X - repmat(m,size(X,1),1)) ./ repmat(s,size(X,1),1);
        
        param{2} = mu;
        param{3} = sigma0;
        
    elseif strcmp(method,'scale')
        
        minV  = min(X,[],1);
        maxV  = max(X,[],1);
        [R,C] = size(X);

        Xnorm = (X - repmat(minV,R,1))*full(spdiags(1./(maxV-minV)',0,C,C));
        
        param{2} = minV;
        param{3} = maxV;
        
    end
    
    % needed for 'zscore', I don't know for 'scale'
    % if some features are always 0, then s=0 and then there is inf values
    Xnorm(isinf(Xnorm)) = 0;
    % also remove nans, not sure why there is some sometimes
    Xnorm(isnan(Xnorm)) = 0;
    
else % param is an input
    
    if strcmp(method,param{1})==0
        error('The normalization method asked is not the one that was used during training.')
    end
    
    if strcmp(method,'zscore')
        mu    = param{2};
        sigma = param{3};
        
        Xnorm = bsxfun(@minus, X, mu);
        Xnorm = bsxfun(@rdivide, Xnorm, sigma);
        
    elseif strcmp(method,'scale')
        minV  = param{2};
        maxV  = param{3};
        [R,C] = size(X);
        Xnorm = (X - repmat(minV,R,1))*full(spdiags(1./(maxV-minV)',0,C,C));
    end
    Xnorm(isinf(Xnorm))   = 0;
    Xnorm(isnan(Xnorm))   = 0;
end