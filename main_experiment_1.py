import numpy as np

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

def main():
    npi = 640
    nbar = 8
    sigma = 2.75  # samp_fro standard deviation (2.75)
    q = 2 ** 15

    # Alice
    A = np.random.randint(0, q, size=(npi, npi))
    S = np.round(sigma * np.random.randn(npi, nbar))
    E = np.round(sigma * np.random.randn(npi, nbar))
    B = np.mod(np.dot(A, S) + E, q)

    # Bob, encryption
    Sp = np.round(sigma * np.random.randn(nbar, npi))
    Ep = np.round(sigma * np.random.randn(nbar, npi))
    Epp = np.round(sigma * np.random.randn(nbar, nbar))

    C1 = np.mod(np.dot(Sp, A) + Ep, q)  # ciphertext 1
    V = np.mod(np.dot(Sp, B) + Epp, q)

    # Given 128-bit message m
    m = np.random.randint(0, 2, size=128)
    bits_per_row = [2, 2, 2, 2, 2, 2, 2, 2]
    M = BitMapper(m, bits_per_row, 8, 8)
    C2 = np.mod(V + M * q / 4, q)  # ciphertext 2

    # Alice again, decryption
    Y = np.mod(C2 - np.dot(C1, S), q)
    Mhat = np.zeros((8, 8), dtype=int)
    for i in range(8):
        for j in range(8):
            if abs(Y[i, j] - q / 4) < q / 8:
                Mhat[i, j] = 1
            elif abs(Y[i, j] - q / 2) < q / 8:
                Mhat[i, j] = 2
            elif abs(Y[i, j] - 3 * q / 4) < q / 8:
                Mhat[i, j] = 3
            else:
                Mhat[i, j] = 0

    mhat = BitDemapper(Mhat, bits_per_row, 8, 8)
    # Test the difference
    Z_BER = np.sum(m != mhat)
    print(Z_BER)

if __name__ == "__main__":
    main()
