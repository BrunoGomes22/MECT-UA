%% ex5
% a)

N = 10;
lambda = 1800;
C = 10;
f = 1000000;
P = 10000;
%{
param1 = zeros(1,N);
param2 = zeros(1,N);
param3 = zeros(1,N);
param4 = zeros(1,N);

fprintf("----Sim1 running for 10 times----\n");

for x = 1:N
    [param1(x), param2(x), param3(x), param4(x)] = Sim1(lambda,C,f,P);
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
%}

% b)

fprintf("----Sim1 running for 100 times----\n");
N = 100;
param1 = zeros(1,N);
param2 = zeros(1,N);
param3 = zeros(1,N);
param4 = zeros(1,N);


for x = 1:N
    [param1(x), param2(x), param3(x), param4(x)] = Sim1(lambda,C,f,P);
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

% c) Sistema M/G/1
% pacotes 64 bytes com prob. de 19%
% pacotes 110 bytes com prob. de 23%
% pacotes 1518 bytes com prob. de 17%
% pacotes 65-109 bytes com probabilidades iguais
% pacotes 111-1517 bytes com probabilidades iguais
fprintf("-----M/G/1 model-----\n")
rate = 1800;
capacity = 10e6;
queue_size = 1000000; 

range_probs = (1 - (0.19 + 0.23 + 0.17))/(109-65+1 + 1517-111+1);

avg_packet_size = 64*0.19 + 110*0.23 + 1518 * 0.17 + sum(65:109)*range_probs + sum(111:1517)*range_probs;

x = 64:1518;

S = (x .* 8)./capacity;
S2 = (x .* 8)./capacity;

for i = 1:length(x)
    if i == 1
        S(i) = S(i) * 0.19;
        S2(i) = S2(i)^2 * 0.19;
    elseif i == (110-64+1)
        S(i) = S(i) * 0.23;
        S2(i) = S2(i)^2 * 0.23;
    elseif i == (1518-64+1)
        S(i) = S(i) * 0.17;
        S2(i) = S2(i)^2 * 0.17;
    else
        S(i) = S(i) * range_probs;
        S2(i) = S2(i)^2 * range_probs;
    end
end

% packet loss (%)
pack_loss = ( (avg_packet_size * (8 / 10^6)) / ((queue_size * (8 / 10^6)) + capacity) ) * 100;

fprintf("Packet loss (%%) = %.4f\n", pack_loss);

% avg. packet delay
WQ = (rate * sum(S2)) / (2*(1-rate*sum(S)));
W = WQ + sum(S);
fprintf("Avg. packet delay (ms) = %2.4f\n", W*1000);

% Throughput(bps) = λ×Packet Size (bits)

throughput = (rate * (avg_packet_size*8))/ 1e6;

fprintf("Throughput (Mbps) = %1.4f\n",throughput);


% d)

fprintf("----Sim1 running for 100 times, with f = 10000 bytes----\n");
f = 10000;

for x = 1:N
    [param1(x), param2(x), param3(x), param4(x)] = Sim1(lambda,C,f,P);
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

% comparing these results with 5.b shows us that the packet loss increases
% drastically because the router queue was reduced from 1000000 bytes to
% 10000 bytes, since there is less size in the queue, less packets will be
% stored in it, therefore increasing the chance of packets being lost
% because the queue fills up quicker. Additionally, it is shown that the
% average packet delay decreases when the queue is smaller because
% transimitting a packet present in the last position of the 10000 bytes
% queue is different from transmitting the last packet of a 1000000 bytes queue,
% the packet in the latter example will spend more time in the queue therefore
% increasing the average packet delay, consequently the max packet delay
% will also increase.
% The throughput decreases a little due to the dropped packets.

% e)
fprintf("----Sim1 running for 100 times, with f = 2000 bytes----\n");
f = 2000;

for x = 1:N
    [param1(x), param2(x), param3(x), param4(x)] = Sim1(lambda,C,f,P);
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

% Comparing the results obtained in this experiment with the results
% obtained both in 5.b and 5.d, it was expected that the packet loss were
% to increase, and the packet delays decreased because the packets spent
% less time in the queue (due to it being shorter).
% The throughput decreased some more because there a more packets being
% dropped.