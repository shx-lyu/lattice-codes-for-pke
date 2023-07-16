def E8Decoding(y):
    n = y.shape[0]
    xhat1 = DnDecoding(y)
    xhat2 = DnDecoding(y - 0.5 * np.ones(n)) + 0.5 * np.ones(n)
    if np.linalg.norm(y - xhat1) <= np.linalg.norm(y - xhat2):
        xhat = xhat1
    else:
        xhat = xhat2
    return xhat
