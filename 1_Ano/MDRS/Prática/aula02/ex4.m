%% ex4
% a)
% calculate avg. packet size

range_probs = (1-(0.19+0.23+0.17))/((109-65+1) + (1517-111+1));

avg_packet_size = 0.19*64 + 0.23*110 + 0.17*1518 + sum(65:109)*range_probs + sum(111:1517)*range_probs;

% calculate transmission time
% 10 Mbps = 10 * 10^6 bits

transmission_time = (avg_packet_size*8)/10e6;
fprintf("Average packet size: %3.2f Bytes\nTransmission time: %.2e seconds\n",avg_packet_size,transmission_time);

% b)
% Throughput(bps) = λ×Packet Size (bits)

throughput = (1000 * avg_packet_size*8)/ 1e6;

fprintf("Throughput: %1.2f Mbps\n",throughput);

% c)
% link capacity (pps) = Link bandwidth (bps) / avg. packet size (bits)

link_capacity = 10e6 / (avg_packet_size*8);

fprintf("Link capacity: %4.2f pps\n", link_capacity);

% d) Sistem de fila de espera M/G/1
% M - processo de chegada markoviano
% G - processo de atendimento de clientes genérico
% 1 - 1 servidor
% quando d é omisso o sistem acomoda um nº infinito de
% clientes (nº de servidores + capacidade da fila de espera)

x = 64:1518;
capacity = 10e6;
rate = 1000;
prop_delay = 10e-6;

S = (x .* 8) ./ (capacity);   %media -> E[X]
S2 = (x .* 8) ./ (capacity);  %segundo momento var. X

for i = 1:length(x)
    if i == 1 %pacotes 64 bytes
        S(i) = S(i) * 0.19;
        S2(i) = S2(i)^2 * 0.19;
    elseif i == (110 - 64 + 1) % pacotes 110 bytes
        S(i) = S(i) * 0.23;
        S2(i) = S2(i)^2 * 0.23;
    elseif i == (1518 - 64 + 1) % pacotes 1518 bytes
        S(i) = S(i) * 0.17;
        S2(i) = S2(i)^2 * 0.17;
    else %restantes pacotes
        S(i) = S(i)*range_probs;
        S2(i) = S2(i)^2 *range_probs;
    end
end

WQ = (rate*sum(S2))/(2*(1-rate*sum(S))); %Sistema M/G/1 slides page 53 

W = WQ + transmission_time + prop_delay;

fprintf("Average packet queuing delay: %.2e\nAverage packet system delay: %.2e\n", WQ,W);

% e)

x = 100:2000; %possible rates
y = (x*sum(S2))./(2*(1-x*sum(S)));

figure(1);
plot(x,y);
title("Average system delay (seconds)")
xlabel("λ (pps)")
grid on

% f)
% x = (% of the link capacity)
% y = average system delay

capacities = [10e6, 20e6, 100e6];

rate_range1 = 100:2000; %when C= 10 Mbps
rate_range2 = 200:4000; %when C= 20 Mbps
rate_range3 = 1000:20000; %when C= 100 Mbps

x1 = (rate_range1 ./ (capacities(1) / (avg_packet_size*8))) * 100;
x2 = (rate_range2 ./ (capacities(2) / (avg_packet_size*8))) * 100;
x3 = (rate_range3 ./ (capacities(3) / (avg_packet_size*8))) * 100;

S1 = (x .* 8) ./ capacities(1);   %media -> E[X]
S12 = (x .* 8) ./ capacities(1);  %segundo momento var. X
S2 = (x .* 8) ./ capacities(2);
S22 = (x .* 8) ./ capacities(2);
S3 = (x .* 8) ./ capacities(3);
S32 = (x .* 8) ./ capacities(3);


for i = 1:length(x)
    if i == 1 %pacotes 64 bytes
        S1(i) = S1(i) * 0.19;
        S12(i) = S12(i)^2 * 0.19;
        S2(i) = S2(i) * 0.19;
        S22(i) = S22(i)^2 * 0.19;
        S3(i) = S3(i) * 0.19;
        S32(i) = S32(i)^2 * 0.19;
    elseif i == (110 - 64 + 1) % pacotes 110 bytes
        S1(i) = S1(i) * 0.23;
        S12(i) = S12(i)^2 * 0.23;
        S2(i) = S2(i) * 0.23;
        S22(i) = S22(i)^2 * 0.23;
        S3(i) = S3(i) * 0.23;
        S32(i) = S32(i)^2 * 0.23;
    elseif i == (1518 - 64 + 1) % pacotes 1518 bytes
        S1(i) = S1(i) * 0.17;
        S12(i) = S12(i)^2 * 0.17;
        S2(i) = S2(i) * 0.17;
        S22(i) = S22(i)^2 * 0.17;
        S3(i) = S3(i) * 0.17;
        S32(i) = S32(i)^2 * 0.17;
    else %restantes pacotes
        S1(i) = S1(i) * range_probs;
        S12(i) = S12(i)^2 * range_probs;
        S2(i) = S2(i) * range_probs;
        S22(i) = S22(i)^2 * range_probs;
        S3(i) = S3(i) * range_probs;
        S32(i) = S32(i)^2 * range_probs;
    end
end

WQ1 = (rate_range1.*sum(S12))./(2*(1-rate_range1.*sum(S1))); %Sistema M/G/1 slides page 53 
WQ2 = (rate_range2.*sum(S22))./(2*(1-rate_range2.*sum(S2)));
WQ3 = (rate_range3.*sum(S32))./(2*(1-rate_range3.*sum(S3)));

transmission_times = zeros(1,3);
for i=1:3
    transmission_times(i) = (avg_packet_size*8)/capacities(i);
end

y1 = WQ1 + transmission_times(1) + prop_delay;
y2 = WQ2 + transmission_times(2) + prop_delay;
y3 = WQ3 + transmission_times(1) + prop_delay;
figure(2);
plot(x1, y1, 'b', x2, y2, 'r', x3, y3, 'g');





