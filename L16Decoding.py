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
