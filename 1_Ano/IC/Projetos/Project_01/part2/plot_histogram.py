import sys
import matplotlib.pyplot as plt

if len(sys.argv) != 3:
    print("Usage: python3 plot_histogram.py <sample_rate>")
    sys.exit(1)


sample_rate = int(sys.argv[1])
sample_file = sys.argv[2]
samples = []
with open(sample_file, 'r') as file:
    for line in file:
        samples.append(int(line.strip()))

left_channel = samples[0::2]
right_channel = samples[1::2]

mid_channel = [(l + r) / 2 for l, r in zip(left_channel, right_channel)]
side_channel = [(l - r) / 2 for l, r in zip(left_channel, right_channel)]


plt.figure(figsize=(12, 10))

plt.subplot(2, 2, 1)
plt.hist(left_channel, bins=256, color='blue', alpha=0.7)
plt.title('Left Channel Histogram')
plt.xlabel('Amplitude')
plt.ylabel('Frequency')

plt.subplot(2, 2, 2)
plt.hist(right_channel, bins=256, color='green', alpha=0.7)
plt.title('Right Channel Histogram')
plt.xlabel('Amplitude')
plt.ylabel('Frequency')

plt.subplot(2, 2, 3)
plt.hist(mid_channel, bins=256, color='purple', alpha=0.7)
plt.title('MID Channel Histogram')
plt.xlabel('Amplitude')
plt.ylabel('Frequency')

plt.subplot(2, 2, 4)
plt.hist(side_channel, bins=256, color='red', alpha=0.7)
plt.title('SIDE Channel Histogram')
plt.xlabel('Amplitude')
plt.ylabel('Frequency')

plt.tight_layout()
plt.show()