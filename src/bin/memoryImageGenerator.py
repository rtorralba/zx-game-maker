#!/usr/bin/env python3

import os
import sys
import hashlib
import numpy as np
import matplotlib.pyplot as plt

# Función que genera un color hex a partir de una cadena
def stringToColor(s):
    hash_object = hashlib.md5(s.encode())
    hex_color = '#' + hash_object.hexdigest()[:6]
    return hex_color

bars = sys.argv[1].split(',')

weight_counts = {}

total = 0
for bar in bars:
    values = bar.split(':')
    if int(values[1]) == 0:
        continue
    total += int(values[1])
    weight_counts[values[0]] = np.array([int(values[1])])

bankMemory = 16383
free = bankMemory - total

weight_counts["Free-Memory"] = np.array([free])

colors = []
labels = []
values = []
for label in weight_counts.keys():
    if label == "Free-Memory":
        colors.append("#999999")
    else:
        colors.append(stringToColor(label))
    labels.append(label + " (" + str(weight_counts[label][0]) + " bytes)")
    values.append(weight_counts[label][0])

# Crear gráfico de pastel
fig, ax = plt.subplots()
wedges, texts, autotexts = ax.pie(values, colors=colors, autopct='%1.1f%%', startangle=90)
ax.axis('equal')  # Para asegurar que el gráfico de pastel sea circular

# Añadir título
ax.set_title(f"Distribución de memoria ({free} bytes libres)")

# Añadir leyendas a la derecha
ax.legend(wedges, labels, title="Categorías", loc="center left", bbox_to_anchor=(1, 0, 0.5, 1))

# Guardar gráfico
if not os.path.exists("dist"):
    os.mkdir("dist")

output_file = sys.argv[2]
if not output_file.endswith(".png"):
    output_file += ".png"

plt.savefig(f"output/{output_file}", format='png', dpi=150, bbox_inches="tight")

print(f"Gráfico guardado en dist/{output_file}")