import pandas as pd
import matplotlib.pyplot as plt
import sys

def plot_histogram(csv_file):
    data = pd.read_csv(csv_file, header=None, names=['Intensity', 'Frequency'])

    plt.figure(figsize=(10, 6))
    plt.bar(data['Intensity'], data['Frequency'], width=1.0, edgecolor='black')
    plt.xlabel('Pixel Intensity')
    plt.ylabel('Frequency')
    plt.title('Grayscale Histogram')
    plt.grid(True)
    plt.show()

if __name__ == "__main__":
    csv_file = sys.argv[1]
    plot_histogram(csv_file)