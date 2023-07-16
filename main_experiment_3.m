% Author: Shanxiang Lyu, lsx07@jnu.edu.cn

clc; clear all; close all;

L16 = [1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,4;
       1,1,1,1,0,2,2,0,2,0,0,2,0,0,0,0;
       1,1,1,0,1,2,0,2,0,2,0,0,2,0,0,0;
       1,1,1,0,0,2,0,0,0,0,0,0,0,0,0,0;
       1,1,0,1,1,0,2,2,0,0,2,0,0,2,0,0;
       1,1,0,1,0,0,2,0,0,0,0,0,0,0,0,0;
       1,1,0,0,1,0,0,2,0,0,0,0,0,0,0,0;
       1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
       1,0,1,1,1,0,0,0,2,2,2,0,0,0,2,0;
       1,0,1,1,0,0,0,0,2,0,0,0,0,0,0,0;
       1,0,1,0,1,0,0,0,0,2,0,0,0,0,0,0;
       1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0;
       1,0,0,1,1,0,0,0,0,0,2,0,0,0,0,0;
       1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0;
       1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0;
       1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

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

% Given 144-bit message m
m = randi([0, 1], 1, 144);

bits_per_row = [3*ones(1, 5), 2*ones(1, 10), 1];

M = BitMapper(m, bits_per_row, 16, 4);

C2 = mod(V + (q / 8) * reshape(L16 * M, 8, 8), q); % ciphertext 2

%Alice again, decryption
Y = mod(C2 - C1 * S, q);
Ybar = reshape(Y / (q / 8), 16, 4); % initialization
Mhat = zeros(16, 4);
for j = 1:4
    xhat(1:16, j) = L16Decoding(Ybar(1:16, j));
    Mhat(1:16, j) = round(L16^(-1) * xhat(1:16, j));
end

mhat = BitDemapper(Mhat, bits_per_row, 16, 4);
% Test the difference
L16_BER = sum(m ~= mhat)
