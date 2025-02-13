import sys
import matplotlib.pyplot as plt

if len(sys.argv) != 4:
    print("Usage: python3 plot_waveform_comparison.py <sample_rate> <original_file> <quantized_file>")
    sys.exit(1)

# Get the sample rate and file names from the command-line arguments
sample_rate = int(sys.argv[1])
original_file = sys.argv[2]
quantized_file = sys.argv[3]

# Read original samples
original_samples = []
with open(original_file, 'r') as file:
    for line in file:
        original_samples.append(int(line.strip()))

# Read quantized samples
quantized_samples = []
with open(quantized_file, 'r') as file:
    for line in file:
        quantized_samples.append(int(line.strip()))

# Separate channels
original_left_channel = original_samples[0::2]
original_right_channel = original_samples[1::2]
quantized_left_channel = quantized_samples[0::2]
quantized_right_channel = quantized_samples[1::2]

time_axis = [i / sample_rate for i in range(len(original_left_channel))]

plt.figure(figsize=(12, 10))

# Plot original left channel
plt.subplot(4, 1, 1)
plt.plot(time_axis, original_left_channel)
plt.title('Original Left Channel')
plt.xlabel('Time (seconds)')
plt.ylabel('Amplitude')

# Plot quantized left channel
plt.subplot(4, 1, 2)
plt.plot(time_axis, quantized_left_channel)
plt.title('Quantized Left Channel')
plt.xlabel('Time (seconds)')
plt.ylabel('Amplitude')

# Plot original right channel
plt.subplot(4, 1, 3)
plt.plot(time_axis, original_right_channel)
plt.title('Original Right Channel')
plt.xlabel('Time (seconds)')
plt.ylabel('Amplitude')

# Plot quantized right channel
plt.subplot(4, 1, 4)
plt.plot(time_axis, quantized_right_channel)
plt.title('Quantized Right Channel')
plt.xlabel('Time (seconds)')
plt.ylabel('Amplitude')

plt.tight_layout()
plt.show()