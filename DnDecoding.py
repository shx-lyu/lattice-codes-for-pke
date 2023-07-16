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
