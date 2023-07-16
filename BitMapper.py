def BitMapper(m, bits_per_row, rows, cols):
    M = np.zeros((rows, cols), dtype=int)
    start_idx = 0
    for row in range(rows):
        num_bits = bits_per_row[row]
        for col in range(cols):
            end_idx = start_idx + num_bits
            M[row, col] = int(''.join(map(str, m[start_idx:end_idx])), 2)
            start_idx = end_idx
    return M
