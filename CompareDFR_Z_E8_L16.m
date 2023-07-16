% author: Shanxiang Lyu, lsx07@jnu.edu.cn

clc;
clear all;
close all;

% Define the E8 matrix
E8 = eye(8);
E8(:, 8) = 0.5 * ones(8, 1);
E8(1, 1) = 2;
for i = 1:6
    E8(i, i+1) = -1;
end

% Define the BW16 (L16) matrix
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

npi = 640;
nbar = 8;
sigma = 5.75; % Sample standard deviation; by default is 2.75
C1 = [];
q = 2^15;

num_monte = 2e3;
BER1 = zeros(num_monte, 1);
BER2 = zeros(num_monte, 1);
BER3 = zeros(num_monte, 1);

for monte = 1:num_monte
    % Alice
    A = randi([0, q-1], npi, npi);
    S = round(sigma * randn(npi, nbar));
    E = round(sigma * randn(npi, nbar));
    B = mod(A * S + E, q);

    % Bob, encryption
    Sp = round(sigma * randn(nbar, npi));
    Ep = round(sigma * randn(nbar, npi));
    Epp = round(sigma * randn(nbar, nbar));

    C1 = mod(Sp * A + Ep, q); % Ciphertext 1
    V = mod(Sp * B + Epp, q); % V matrix

    % Given 128-bit message m
    m = randi([0, 1], 1, 128);

    %---------------Z based encoding and decoding----------------------%
    bits_per_row = [2, 2, 2, 2, 2, 2, 2, 2];
    M = BitMapper(m, bits_per_row, 8, 8);
    C2 = mod(V + M*q/4, q); % Ciphertext 2

    % Alice again, decryption
    Y = mod(C2 - C1 * S, q);
    Mhat = zeros(8, 8);
    for i = 1:8
        for j = 1:8
            if abs(Y(i, j) - q/4) < q/8
                Mhat(i, j) = 1;
            elseif abs(Y(i, j) - q/2) < q/8
                Mhat(i, j) = 2;
            elseif abs(Y(i, j) - 3*q/4) < q/8
                Mhat(i, j) = 3;
            else
                Mhat(i, j) = 0;
            end
        end
    end

    mhat = BitDemapper(Mhat, bits_per_row, 8, 8);
    % Test the difference
    BER1(monte) = sum(m ~= mhat) > 0;

    %---------------E8 based encoding and decoding----------------------%
    bits_per_row = [1, 2, 2, 2, 2, 2, 2, 3];

    M = BitMapper(m, bits_per_row, 8, 8);
    C2 = mod(V + (q/4)*E8*M, q); % Ciphertext 2

    % Alice again, decryption
    Y = mod(C2 - C1 * S, q);
    Ybar = Y / (q/4); % Initialization
    Mhat = zeros(8, 8);
    for j = 1:8
        xhat(1:8, j) = E8Decoding(Ybar(1:8, j));
        Mhat(1:8, j) = round(E8^(-1) * xhat(1:8, j));
    end

    mhat = BitDemapper(Mhat, bits_per_row, 8, 8);
    % Test the difference
    BER2(monte) = sum(m ~= mhat) > 0;

    %---------------BW16 based encoding and decoding----------------------%
    % Given 144-bit message m
    m = randi([0, 1], 1, 144);

    bits_per_row = [3*ones(1, 5), 2*ones(1, 10), 1];

    M = BitMapper(m, bits_per_row, 16, 4);

    C2 = mod(V + (q/8) * reshape(L16 * M, 8, 8), q); % Ciphertext 2

    % Alice again, decryption
    Y = mod(C2 - C1 * S, q);
    Ybar = reshape(Y / (q/8), 16, 4); % Initialization
    Mhat = zeros(16, 4);
    for j = 1:4
        xhat(1:16, j) = L16Decoding(Ybar(1:16, j));
        Mhat(1:16, j) = round(L16^(-1) * xhat(1:16, j));
    end

    mhat = BitDemapper(Mhat, bits_per_row, 16, 4);
    % Test the difference
    BER3(monte) = sum(m ~= mhat) > 0;
end

Z_BER = mean(BER1)
E8_BER = mean(BER2)
L16_BER = mean(BER3)
