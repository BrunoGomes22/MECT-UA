import sys
import matplotlib.pyplot as plt

if len(sys.argv) != 3:
    print("Usage: python3 plot_waveform.py <sample_rate> <sample_file>")
    sys.exit(1)

sample_rate = int(sys.argv[1])
sample_file = sys.argv[2]

samples = []
with open(sample_file, 'r') as file:
    for line in file:
        samples.append(int(line.strip()))

left_channel = samples[0::2]
right_channel = samples[1::2]

time_axis = [i / sample_rate for i in range(len(left_channel))]

plt.figure(figsize=(10, 8))

plt.subplot(2, 1, 1)
plt.plot(time_axis, left_channel)
plt.title('Left Channel')
plt.xlabel('Time (seconds)')
plt.ylabel('Amplitude')

plt.subplot(2, 1, 2)
plt.plot(time_axis, right_channel)
plt.title('Right Channel')
plt.xlabel('Time (seconds)')
plt.ylabel('Amplitude')

plt.tight_layout()
plt.show()