function M = BitMapper(m,bits_per_row,rows,cols)

if nargin <4
     % Define the number of bits per row in M
     bits_per_row = [2, 2, 2, 2, 2, 2, 2, 2];
     % Define the size of the information matrix (8x8) and the number of bits per row
    rows = 8;
    cols = 8;
end

 
    % Initialize the information matrix M
    M = zeros(rows, cols);

    % Fill the matrix row by row with the message bits
    start_idx = 1;
    for row = 1:rows
        num_bits = bits_per_row(row);
        for col = 1:cols
            end_idx = start_idx + num_bits - 1;
           % M(row, col) = bi2de(m(start_idx:end_idx), 'left-msb'); % Convert binary to decimal
            M(row, col) = bin2dec_custom(m(start_idx:end_idx)); % Convert binary to decimal
            start_idx = end_idx + 1;
        end
    end
end
