function binary_vector = dec2bin_custom(decimal_value, num_bits)
    % Convert a decimal integer to a binary vector
    % Input: decimal_value - the decimal integer to be converted
    %        num_bits - optional parameter specifying the number of bits in the binary vector
    %                   If not provided, the function will automatically determine the minimum
    %                   number of bits required to represent the decimal value.
    % Output: binary_vector - the corresponding binary vector (row vector)
    
    % Check if the number of bits is provided; if not, determine the minimum number of bits required
    if nargin < 2
        num_bits = ceil(log2(decimal_value + 1));
    end
    
    % Convert the decimal value to a binary string with leading zeros
    binary_string = dec2bin(decimal_value, num_bits);
    
    % Convert the binary string to a row vector of numeric values
    binary_vector = (double(binary_string') - '0')';
end
