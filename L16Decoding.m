function [v_final] = L16Decoding(y)
% Function decoding algorithm of Lambda16
% Author: Shanxiang Lyu, lsx07@jnu.edu.cn

% Input:
%   y: Query point y
% Output:
%   v_final: Closest vector to y

% Coset representatives for Lambda16
G1 = [1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0;
      1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0;
      1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0;
      1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0;
      1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]';

n = 16;
Dist = zeros(1, 32);
d = zeros(n, 32);
vhat = zeros(n, 32);

% Comparing the coset representatives
for k = 1:32
    % Decoding for each 2D2 + dk
    %d(1:n, k) = G1 * (de2bi(k - 1, 5)'); % G1 times a binary vector of 5 dimensions
    d(1:n,k)=(dec2bin_custom(k-1,5)*G1)';
    
    % y = 2D_{16} * x + dk + n;
    ybar = (y - d(1:n, k)) / 2;
    vhat(1:n, k) = 2 * DnDecoding(ybar) + d(1:n, k); % 32 possible closest vectors
    Dist(k) = norm(y - vhat(1:n, k));
end

% Choose the closest vector
v_final = vhat(1:n, find(Dist == min(Dist)));
end
