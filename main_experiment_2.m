% Author: Shanxiang Lyu, lsx07@jnu.edu.cn

clc; clear all; close all;
npi = 640; nbar = 8;
sigma = 2.75; % samp_fro standard deviation
C1 = [];
q = 2^15;

% Alice
A = randi([0, q - 1], npi, npi);
S = round(sigma * randn(npi, nbar));
E = round(sigma * randn(npi, nbar));
B = mod(A * S + E, q);

% Bob, encryption
Sp = round(sigma * randn(nbar, npi));
Ep = round(sigma * randn(nbar, npi));
Epp = round(sigma * randn(nbar, nbar));

C1 = mod(Sp * A + Ep, q); % ciphertext 1
V = mod(Sp * B + Epp, q);

% Given 128-bit message m
m = randi([0, 1], 1, 128);

% Define the E8 matrix
E8 = eye(8);
E8(:, 8) = 0.5 * ones(8, 1);
E8(1, 1) = 2;
for i = 1:6
    E8(i, i + 1) = -1;
end
bits_per_row = [1, 2, 2, 2, 2, 2, 2, 3];

M = BitMapper(m, bits_per_row, 8, 8);
C2 = mod(V + (q / 4) * E8 * M, q); % ciphertext 2

% Alice again, decryption
Y = mod(C2 - C1 * S, q);
Ybar = Y / (q / 4); % initialization
Mhat = zeros(8, 8);
for j = 1:8
    xhat(1:8, j) = E8Decoding(Ybar(1:8, j));
    Mhat(1:8, j) = round(E8^(-1) * xhat(1:8, j));
end

mhat = BitDemapper(Mhat, bits_per_row, 8, 8);
% Test the difference
E8_BER = sum(m ~= mhat)
