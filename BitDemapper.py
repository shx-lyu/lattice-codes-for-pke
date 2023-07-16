def BitDemapper(M, bits_per_row, rows, cols):
    m = []
    start_idx = 0
    for row in range(rows):
        num_bits = bits_per_row[row]
        for col in range(cols):
            end_idx = start_idx + num_bits
            binary_representation = [int(i) for i in format(M[row, col] % (2 ** num_bits), '0{}b'.format(num_bits))]
            m.extend(binary_representation)
            start_idx = end_idx
    return m
