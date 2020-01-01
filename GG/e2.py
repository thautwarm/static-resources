# 为了随时复现

from matplotlib import pyplot as plt
import numpy as np
fig, ax = plt.subplots()
x = np.linspace(0, 100)
y2 = np.sqrt(2500 - (x - 50)**2) + 50
y1 = 100 - y2


ax.add_artist(plt.Rectangle((-1, -1), 101, 101, color='lightblue', alpha=0.8))
ax.add_artist(plt.Rectangle((-1, 24), 101, 51, color='green', alpha=0.8))
ax.add_artist(plt.Rectangle((24, -1), 51, 101, color='green', alpha=0.8))



plt.plot(x, y1, 'm')
plt.plot(x, y2, 'm')
plt.axis('equal', adjustable='datalim')
plt.axis('off')
plt.scatter(*zip(*[(i + 12.5, j + 12.5) for i in range(0, 100, 25) for j in range(0, 100, 25)]),
            c='black')


plt.text(20, 40, "sum this circle!", fontdict = {
        'family': 'serif',
        'color':  'black',
        'weight': 'normal',
        'size': 15,
        })
plt.text(-10, -5, "$ 0 $", fontdict = {
        'family': 'serif',
        'color':  'black',
        'weight': 'normal',
        'size': 25,
})

plt.savefig("e2.png", dpi=300)