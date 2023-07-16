function [xhat] = DnDecoding(y)
% Function decoding algorithm of Dn Lattices
% Author: Shanxiang Lyu, lsx07@jnu.edu.cn

% Input:
%   y: Query point y
% Output:
%   xhat: Estimated lattice point

% Define f
f = round(y);
delta = abs(y - f);
k = find(delta == max(delta));

% Define g
g = f;
if f(k) <= y(k)
    g(k) = f(k) + 1;
else
    g(k) = f(k) - 1;
end

% Estimate lattice point xhat
if mod(sum(f), 2) == 0
    xhat = f;
else
    xhat = g;
end
end
