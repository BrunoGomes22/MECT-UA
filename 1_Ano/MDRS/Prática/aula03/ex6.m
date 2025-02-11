%% 6
% b)

lambda = 1800;         %packet rate (packets/sec)
C = 10;                %link bandwidth (Mbps)
f = 1000000;           %queue size (Bytes)
P = 10000;             %number of packets (stopping criterium)
b = 10^-6;           %bit error rate (BER)

N = 100;

param1 = zeros(1,N);
param2 = zeros(1,N);
param3 = zeros(1,N);
param4 = zeros(1,N);

fprintf("----Sim2 running for 100 times----\n");

for x = 1:N

  [param1(x), param2(x), param3(x), param4(x)]  = Sim2(lambda,C,f,P,b);

end

alfa = 0.1; % 90% confidence interval
media = mean(param1);
term = norminv(1-alfa/2)*sqrt(var(param1)/N);
fprintf('PacketLoss (%%) = %.2e +- %.2e\n',media,term)
media = mean(param2);
term = norminv(1-alfa/2)*sqrt(var(param2)/N);
fprintf('Av. Packet Delay (ms) = %.2e +- %.2e\n',media,term)
media = mean(param3);
term = norminv(1-alfa/2)*sqrt(var(param3)/N);
fprintf('Max. Packet Delay (ms) = %.2e +- %.2e\n',media,term)
media = mean(param4);
term = norminv(1-alfa/2)*sqrt(var(param4)/N);
fprintf('Throughput (Mbps) = %.2e +- %.2e\n',media,term)

% comparing the results obtained with the ones obtained in 5.b we can see
% that the packet loss increased by a small amount (aprox. 0.5%) due to the
% new parameter introduced into the simulation (BER = 10^-6), additionaly the
% throughput decreased because some packets are being dropped, the bigger
% packets are also the most prone to being dropped due to having more bits.
% The other parameters such as avg. packet delay and max. packet delay are
% not influenced because those factors are usually influenced by the queue
% size. 
% Additionaly we can also get the value of the throughput with no loss if
% we do the following calculation throughput_noloss = throughput / (1-packet_loss)

% c)

fprintf("-----Sim2 running for 100 times, with f= 10000 bytes-----\n");

f = 10000;

for x = 1:N

  [param1(x), param2(x), param3(x), param4(x)]  = Sim2(lambda,C,f,P,b);

end

alfa = 0.1; % 90% confidence interval
media = mean(param1);
term = norminv(1-alfa/2)*sqrt(var(param1)/N);
fprintf('PacketLoss (%%) = %.2e +- %.2e\n',media,term)
media = mean(param2);
term = norminv(1-alfa/2)*sqrt(var(param2)/N);
fprintf('Av. Packet Delay (ms) = %.2e +- %.2e\n',media,term)
media = mean(param3);
term = norminv(1-alfa/2)*sqrt(var(param3)/N);
fprintf('Max. Packet Delay (ms) = %.2e +- %.2e\n',media,term)
media = mean(param4);
term = norminv(1-alfa/2)*sqrt(var(param4)/N);
fprintf('Throughput (Mbps) = %.2e +- %.2e\n',media,term)

% Comparing the results obtained here with the results obtained in 5.d we
% can see that the the packet loss is higher in 6.c, and this is because
% even though the queue sizes are equal in both simulations, in 6.c we have
% a bit error rate of 10^-6, so packets have a chance of being discarded if
% there are errors present in them.
% The throughput in this simulation is less than 5.d because of the reason
% explained above, so we have a shorter queue and in addition, the link has
% a probability of receiving packets with errors.

fprintf("-----Sim2 running for 100 times, with f= 2000 bytes-----\n");

f = 2000;

for x = 1:N

  [param1(x), param2(x), param3(x), param4(x)]  = Sim2(lambda,C,f,P,b);

end

alfa = 0.1; % 90% confidence interval
media = mean(param1);
term = norminv(1-alfa/2)*sqrt(var(param1)/N);
fprintf('PacketLoss (%%) = %.2e +- %.2e\n',media,term)
media = mean(param2);
term = norminv(1-alfa/2)*sqrt(var(param2)/N);
fprintf('Av. Packet Delay (ms) = %.2e +- %.2e\n',media,term)
media = mean(param3);
term = norminv(1-alfa/2)*sqrt(var(param3)/N);
fprintf('Max. Packet Delay (ms) = %.2e +- %.2e\n',media,term)
media = mean(param4);
term = norminv(1-alfa/2)*sqrt(var(param4)/N);
fprintf('Throughput (Mbps) = %.2e +- %.2e\n',media,term)

% Predictably, the packet loss in this simulation is also marginally higher
% due to the observations made above, consequently the throughput is also
% lower.