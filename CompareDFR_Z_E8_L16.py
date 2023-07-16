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

def L16Decoding(y):
    G1 = np.array([[1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
                   [1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0],
                   [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
                   [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0],
                   [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]], dtype=int)

    n = 16
    Dist = np.zeros(32)
    xhat = np.zeros((n, 32), dtype=int)
    for k in range(32):
        d = np.dot(G1.transpose(), np.unpackbits(np.array([k], dtype=np.uint8))[-5:])
        ybar = (y - d) / 2
        vhat = 2 * DnDecoding(ybar) + d
        xhat[:, k] = vhat
        Dist[k] = np.linalg.norm(y - vhat)
    v_final = xhat[:, np.argmin(Dist)]
    return v_final

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
    E8 = np.eye(8)
    E8[:, 7] = 0.5 * np.ones(8)
    E8[0, 0] = 2
    for i in range(6):
        E8[i, i + 1] = -1

    L16 = np.array([[1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,4],
                    [1,1,1,1,0,2,2,0,2,0,0,2,0,0,0,0],
                    [1,1,1,0,1,2,0,2,0,2,0,0,2,0,0,0],
                    [1,1,1,0,0,2,0,0,0,0,0,0,0,0,0,0],
                    [1,1,0,1,1,0,2,2,0,0,2,0,0,2,0,0],
                    [1,1,0,1,0,0,2,0,0,0,0,0,0,0,0,0],
                    [1,1,0,0,1,0,0,2,0,0,0,0,0,0,0,0],
                    [1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                    [1,0,1,1,1,0,0,0,2,2,2,0,0,0,2,0],
                    [1,0,1,1,0,0,0,0,2,0,0,0,0,0,0,0],
                    [1,0,1,0,1,0,0,0,0,2,0,0,0,0,0,0],
                    [1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0],
                    [1,0,0,1,1,0,0,0,0,0,2,0,0,0,0,0],
                    [1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0],
                    [1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
                    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]])

    npi = 640
    nbar = 8
    sigma = 5.75
    C1 = []
    q = 2 ** 15

    num_monte = int(2e3)
    BER1 = np.zeros(num_monte, dtype=int)
    BER2 = np.zeros(num_monte, dtype=int)
    BER3 = np.zeros(num_monte, dtype=int)

    for monte in range(num_monte):
        # Alice
        A = np.random.randint(0, q, size=(npi, npi))
        S = np.round(sigma * np.random.randn(npi, nbar))
        E = np.round(sigma * np.random.randn(npi, nbar))
        B = np.mod(np.dot(A, S) + E, q)

        # Bob, encryption
        Sp = np.round(sigma * np.random.randn(nbar, npi))
        Ep = np.round(sigma * np.random.randn(nbar, npi))
        Epp = np.round(sigma * np.random.randn(nbar, nbar))

        C1 = np.mod(np.dot(Sp, A) + Ep, q)  # Ciphertext 1
        V = np.mod(np.dot(Sp, B) + Epp, q)  # V matrix

        # Given 128-bit message m
        m = np.random.randint(0, 2, size=128)

        # Z based encoding and decoding
        bits_per_row = [2, 2, 2, 2, 2, 2, 2, 2]
        M = BitMapper(m, bits_per_row, 8, 8)
        C2 = np.mod(V + M * q / 4, q)  # Ciphertext 2

        # Alice again, decryption
        Y = np.mod(C2 - np.dot(C1, S), q)
        Mhat = np.zeros((8, 8), dtype=int)
        for i in range(8):
            for j in range(8):
                if np.abs(Y[i, j] - q / 4) < q / 8:
                    Mhat[i, j] = 1
                elif np.abs(Y[i, j] - q / 2) < q / 8:
                    Mhat[i, j] = 2
                elif np.abs(Y[i, j] - 3 * q / 4) < q / 8:
                    Mhat[i, j] = 3
                else:
                    Mhat[i, j] = 0

        mhat = BitDemapper(Mhat, bits_per_row, 8, 8)
        # Test the difference
        BER1[monte] = np.sum(m != mhat) > 0

        # E8 based encoding and decoding
        bits_per_row = [1, 2, 2, 2, 2, 2, 2, 3]

        M = BitMapper(m, bits_per_row, 8, 8)
        C2 = np.mod(V + (q / 4) * np.dot(E8, M), q)  # Ciphertext 2

        # Alice again, decryption
        Y = np.mod(C2 - np.dot(C1, S), q)
        Ybar = Y / (q / 4)  # Initialization
        Mhat = np.zeros((8, 8), dtype=int)
        for j in range(8):
            xhat = E8Decoding(Ybar[:8, j])
            Mhat[:8, j] = np.round(np.dot(np.linalg.inv(E8), xhat))

        mhat = BitDemapper(Mhat, bits_per_row, 8, 8)
        # Test the difference
        BER2[monte] = np.sum(m != mhat) > 0

        # BW16 based encoding and decoding
        # Given 144-bit message m
        m = np.random.randint(0, 2, size=144)

        bits_per_row = [3] * 5 + [2] * 10 + [1]

        M = BitMapper(m, bits_per_row, 16, 4)

        C2 = np.mod(V + (q / 8) * np.reshape(np.dot(L16, M), (8, 8)), q)  # Ciphertext 2

        # Alice again, decryption
        Y = np.mod(C2 - np.dot(C1, S), q)
        Ybar = np.reshape(Y / (q / 8), (16, 4))  # Initialization
        Mhat = np.zeros((16, 4), dtype=int)
        for j in range(4):
            xhat = L16Decoding(Ybar[:16, j])
            Mhat[:16, j] = np.round(np.dot(np.linalg.inv(L16), xhat))

        mhat = BitDemapper(Mhat, bits_per_row, 16, 4)
        # Test the difference
        BER3[monte] = np.sum(m != mhat) > 0

    Z_BER = np.mean(BER1)
    E8_BER = np.mean(BER2)
    L16_BER = np.mean(BER3)

    print("Z-based BER:", Z_BER)
    print("E8-based BER:", E8_BER)
    print("BW16-based BER:", L16_BER)

if __name__ == "__main__":
    main()
