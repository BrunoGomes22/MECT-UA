%% Task 1

% INPUT PARAMETERS:
%  lambda - packet rate (packets/sec)
%  C      - link bandwidth (Mbps)
%  f      - queue size (Bytes)
%  P      - number of packets (stopping criterium)
%  b      - bit error rate (BER)

lambdas = [1500, 1600, 1700, 1800, 1900];
C = 10;
f = 10000;
P = 100000;
b = 10^-4;

N = 20;

av_pack_delay = zeros(1,5);
packet_loss = zeros(1,5);
int_errors_delay = zeros(1,5);
int_errors_loss = zeros(1,5);


alfa = 0.1; % 90% confidence interval

for idx = 1:length(lambdas)
    param1 = zeros(1,N);
    param2 = zeros(1,N);
    for x = 1:N
        [param1(x), param2(x)]  = Sim2(lambdas(idx),C,f,P,b);
    end
    av_pack_delay(idx) = mean(param2);
    int_errors_delay(idx) = norminv(1-alfa/2)*sqrt(var(param2)/N);
    packet_loss(idx) = mean(param1);
    int_errors_loss(idx) = norminv(1-alfa/2)*sqrt(var(param1)/N);
end

figure(1)
bar(lambdas, av_pack_delay)
grid on
hold on


er = errorbar(lambdas,av_pack_delay,int_errors_delay);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';

xlabel('Packet rate (packets/sec)');
ylabel('Average Packet Delay (ms)');
title('Average Packet Delay for several packet rates');
hold off;

figure(2)
bar(lambdas,packet_loss)
grid on
hold on

er = errorbar(lambdas,packet_loss,int_errors_loss);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';

xlabel('Packet rate (packets/sec)');
ylabel('Packet Loss (%%)');
title('Packet Loss for several packet rates');
hold off;




