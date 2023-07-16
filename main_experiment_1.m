% Author: Shanxiang Lyu, lsx07@jnu.edu.cn

clc; clear all; close all;

npi = 640; nbar = 8;
sigma = 2.75; % samp_fro standard deviation (2.75)
C1 = [];
q = 2^15;

% Alice
A = randi([0, q-1], npi, npi);
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
bits_per_row = [2, 2, 2, 2, 2, 2, 2, 2];
M = BitMapper(m, bits_per_row, 8, 8);
C2 = mod(V + M * q / 4, q); % ciphertext 2

% Alice again, decryption
Y = mod(C2 - C1 * S, q);
Mhat = zeros(8, 8);
for i = 1:8
    for j = 1:8
        if abs(Y(i, j) - q / 4) < q / 8
            Mhat(i, j) = 1;
        elseif abs(Y(i, j) - q / 2) < q / 8
            Mhat(i, j) = 2;
        elseif abs(Y(i, j) - 3 * q / 4) < q / 8
            Mhat(i, j) = 3;
        else
            Mhat(i, j) = 0;
        end
    end
end

mhat = BitDemapper(Mhat, bits_per_row, 8, 8);
% Test the difference
Z_BER = sum(m ~= mhat)
