function m = BitDemapper(M,bits_per_row,rows,cols)
 
if nargin <4
     % Define the number of bits per row in M
     bits_per_row = [2, 2, 2, 2, 2, 2, 2, 2];
 % Define the size of the information matrix (8x8) and the number of bits per row
    rows = 8;
    cols = 8;
end
 
    % Initialize the message vector m
    m = [];

    % Extract the bits from M row by row and convert to binary representation
    for row = 1:rows
        num_bits = bits_per_row(row);
        for col = 1:cols
            %binary_representation = de2bi(mod(M(row, col),2^num_bits), num_bits, 'left-msb'); % Convert decimal to binary
            binary_representation = dec2bin_custom(mod(M(row, col),2^num_bits), num_bits); % Convert decimal to binary
            m = [m, binary_representation];
        end
    end
end
