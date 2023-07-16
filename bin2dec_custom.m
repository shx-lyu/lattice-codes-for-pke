function decimal_value = bin2dec_custom(binary_vector)
    % Convert a binary vector to a decimal integer
    % Input: binary_vector - a row or column vector containing binary digits (0 or 1)
    % Output: decimal_value - the corresponding decimal integer
    
    % Check if the input is a row vector; if not, transpose it to ensure it's a row vector
    if size(binary_vector, 1) > 1
        binary_vector = binary_vector';
    end
    
    % Convert binary vector to a string representation
    binary_string = char('0' + binary_vector);
    
    % Use the built-in bin2dec function to convert the binary string to a decimal value
    decimal_value = bin2dec(binary_string);
end
