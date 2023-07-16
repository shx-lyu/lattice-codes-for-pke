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

def E8Decoding(y):
    n = y.shape[0]
    xhat1 = DnDecoding(y)

    xhat2 = DnDecoding(y - 0.5 * np.ones(n)) + 0.5 * np.ones(n)

    if np.linalg.norm(y - xhat1) <= np.linalg.norm(y - xhat2):
        xhat = xhat1
    else:
        xhat = xhat2

    return xhat

def DnDecoding(y):
    f = np.round(y)
    delta = np.abs(y - f)
    k = np.argmax(delta)
    g = f.copy()
    if f[k] <= y[k]:
        g[k] = f[k] + 1
    else:
        g[k] = f[k] - 1
    if np.sum(f) % 2 == 0:
        xhat = f
    else:
        xhat = g
    return xhat

def main():
    npi = 640
    nbar = 8
    sigma = 2.75  # samp_fro standard deviation
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
    bits_per_row = [1, 2, 2, 2, 2, 2, 2, 3]

    M = BitMapper(m, bits_per_row, 8, 8)
    C2 = np.mod(V + (q / 4) * np.dot(E8, M), q)  # ciphertext 2

    # Alice again, decryption
    Y = np.mod(C2 - np.dot(C1, S), q)
    Ybar = Y / (q / 4)  # initialization
    Mhat = np.zeros((8, 8), dtype=int)
    for j in range(8):
        xhat = E8Decoding(Ybar[:8, j])
        Mhat[:8, j] = np.round(np.dot(np.linalg.inv(E8), xhat))

    mhat = BitDemapper(Mhat, bits_per_row, 8, 8)
    # Test the difference
    E8_BER = np.sum(m != mhat)
    print(E8_BER)

if __name__ == "__main__":
    main()
