function [xhat] = E8Decoding(y)
% Function decoding algorithm of E8 Lattices
% Author: Shanxiang Lyu, lsx07@jnu.edu.cn

% Input:
%   y: Query point y
% Output:
%   xhat: Lattice point

n = size(y, 1);

xhat1 = DnDecoding(y);
xhat2 = DnDecoding(y - 0.5 * ones(n, 1)) + 0.5 * ones(n, 1);

if norm(y - xhat1) <= norm(y - xhat2)
    xhat = xhat1;
else
    xhat = xhat2;
end
end
