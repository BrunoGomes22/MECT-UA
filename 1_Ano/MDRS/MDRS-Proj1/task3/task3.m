%% Task 3

% a)


%{
lambda = 1500;
C = 10;
f = 10000;
n = [10,20,30,40];
P = 100000;

N = 20;

param1 = zeros(1,N);
param2 = zeros(1,N);
param3 = zeros(1,N);
param4 = zeros(1,N);

avg_pack_delay_data = zeros(1,4);
avg_pack_delay_inter = zeros(1,4);

pack_loss_data = zeros(1,4);
pack_loss_data_inter = zeros(1,4);

avg_pack_delay_voip = zeros(1,4);
avg_pack_delay_voip_inter = zeros(1,4);

pack_loss_voip = zeros(1,4);
pack_loss_voip_inter = zeros(1,4);

alfa = 0.1;

for idx = 1:length(n)
    for x = 1:N
        [param1(x), param2(x), param3(x), param4(x)]  = Sim3(lambda,C,f,P,n(idx));
    end
    avg_pack_delay_data(idx) = mean(param3);
    avg_pack_delay_inter(idx) = norminv(1-alfa/2)*sqrt(var(param3)/N);

    pack_loss_data(idx) = mean(param1);
    pack_loss_data_inter(idx) = norminv(1-alfa/2)*sqrt(var(param1)/N);

    avg_pack_delay_voip(idx) = mean(param4);
    avg_pack_delay_voip_inter(idx) = norminv(1-alfa/2)*sqrt(var(param4)/N);

    pack_loss_voip(idx) = mean(param2);
    pack_loss_voip_inter(idx) = norminv(1-alfa/2)*sqrt(var(param2)/N);
end


% Create bar chart for average packet delay
figure;
hold on;
bar_data = [avg_pack_delay_data; avg_pack_delay_voip]';
bar_handle = bar(n, bar_data, 'grouped');
% Adjust error bar positions
x_data = bar_handle(1).XEndPoints;
x_voip = bar_handle(2).XEndPoints;
errorbar(x_data, avg_pack_delay_data, avg_pack_delay_inter, 'k', 'linestyle', 'none');
errorbar(x_voip, avg_pack_delay_voip, avg_pack_delay_voip_inter, 'k', 'linestyle', 'none');
hold off;
title('Average Packet Delay');
xlabel('VoIP flows');
ylabel('Delay (ms)');
legend('Data', 'VoIP');
grid on;

% Create bar chart for packet loss
figure;
hold on;
bar_loss = [pack_loss_data; pack_loss_voip]';
bar_handle = bar(n, bar_loss, 'grouped');
% Adjust error bar positions
x_data = bar_handle(1).XEndPoints;
x_voip = bar_handle(2).XEndPoints;
errorbar(x_data, pack_loss_data, pack_loss_data_inter, 'k', 'linestyle', 'none');
errorbar(x_voip, pack_loss_voip, pack_loss_voip_inter, 'k', 'linestyle', 'none');
hold off;
title('Packet Loss');
xlabel('VoIP flows');
ylabel('Loss (%)');
legend('Data', 'VoIP');
grid on;



% b)

lambda = 1500;
C = 10;
f = 10000;
n = [10,20,30,40];
P = 100000;

N = 20;

param1 = zeros(1,N);
param2 = zeros(1,N);
param3 = zeros(1,N);
param4 = zeros(1,N);

avg_pack_delay_data = zeros(1,4);
avg_pack_delay_inter = zeros(1,4);

pack_loss_data = zeros(1,4);
pack_loss_data_inter = zeros(1,4);

avg_pack_delay_voip = zeros(1,4);
avg_pack_delay_voip_inter = zeros(1,4);

pack_loss_voip = zeros(1,4);
pack_loss_voip_inter = zeros(1,4);

alfa = 0.1;

for idx = 1:length(n)
    for x = 1:N
        [param1(x), param2(x), param3(x), param4(x)]  = Sim4(lambda,C,f,P,n(idx));
    end
    avg_pack_delay_data(idx) = mean(param3);
    avg_pack_delay_inter(idx) = norminv(1-alfa/2)*sqrt(var(param3)/N);

    pack_loss_data(idx) = mean(param1);
    pack_loss_data_inter(idx) = norminv(1-alfa/2)*sqrt(var(param1)/N);

    avg_pack_delay_voip(idx) = mean(param4);
    avg_pack_delay_voip_inter(idx) = norminv(1-alfa/2)*sqrt(var(param4)/N);

    pack_loss_voip(idx) = mean(param2);
    pack_loss_voip_inter(idx) = norminv(1-alfa/2)*sqrt(var(param2)/N);
end


% Create bar chart for average packet delay
figure;
hold on;
bar_data = [avg_pack_delay_data; avg_pack_delay_voip]';
bar_handle = bar(n, bar_data, 'grouped');
% Adjust error bar positions
x_data = bar_handle(1).XEndPoints;
x_voip = bar_handle(2).XEndPoints;
errorbar(x_data, avg_pack_delay_data, avg_pack_delay_inter, 'k', 'linestyle', 'none');
errorbar(x_voip, avg_pack_delay_voip, avg_pack_delay_voip_inter, 'k', 'linestyle', 'none');
hold off;
title('Average Packet Delay');
xlabel('VoIP flows');
ylabel('Delay (ms)');
legend('Data', 'VoIP');
grid on;

% Create bar chart for packet loss
figure;
hold on;
bar_loss = [pack_loss_data; pack_loss_voip]';
bar_handle = bar(n, bar_loss, 'grouped');
% Adjust error bar positions
x_data = bar_handle(1).XEndPoints;
x_voip = bar_handle(2).XEndPoints;
errorbar(x_data, pack_loss_data, pack_loss_data_inter, 'k', 'linestyle', 'none');
errorbar(x_voip, pack_loss_voip, pack_loss_voip_inter, 'k', 'linestyle', 'none');
hold off;
title('Packet Loss');
xlabel('VoIP flows');
ylabel('Loss (%)');
legend('Data', 'VoIP');
grid on;


% d)


lambda = 1500;
C = 10;
f = 10000;
n = [10,20,30,40];
P = 100000;
p = 90;

N = 20;

param1 = zeros(1,N);
param2 = zeros(1,N);
param3 = zeros(1,N);
param4 = zeros(1,N);

avg_pack_delay_data = zeros(1,4);
avg_pack_delay_inter = zeros(1,4);

pack_loss_data = zeros(1,4);
pack_loss_data_inter = zeros(1,4);

avg_pack_delay_voip = zeros(1,4);
avg_pack_delay_voip_inter = zeros(1,4);

pack_loss_voip = zeros(1,4);
pack_loss_voip_inter = zeros(1,4);

alfa = 0.1;

for idx = 1:length(n)
    for x = 1:N
        [param1(x), param2(x), param3(x), param4(x)]  = Sim4A(lambda,C,f,P,n(idx),p);
    end
    avg_pack_delay_data(idx) = mean(param3);
    avg_pack_delay_inter(idx) = norminv(1-alfa/2)*sqrt(var(param3)/N);

    pack_loss_data(idx) = mean(param1);
    pack_loss_data_inter(idx) = norminv(1-alfa/2)*sqrt(var(param1)/N);

    avg_pack_delay_voip(idx) = mean(param4);
    avg_pack_delay_voip_inter(idx) = norminv(1-alfa/2)*sqrt(var(param4)/N);

    pack_loss_voip(idx) = mean(param2);
    pack_loss_voip_inter(idx) = norminv(1-alfa/2)*sqrt(var(param2)/N);
end


% Create bar chart for average packet delay
figure;
hold on;
bar_data = [avg_pack_delay_data; avg_pack_delay_voip]';
bar_handle = bar(n, bar_data, 'grouped');
% Adjust error bar positions
x_data = bar_handle(1).XEndPoints;
x_voip = bar_handle(2).XEndPoints;
errorbar(x_data, avg_pack_delay_data, avg_pack_delay_inter, 'k', 'linestyle', 'none');
errorbar(x_voip, avg_pack_delay_voip, avg_pack_delay_voip_inter, 'k', 'linestyle', 'none');
hold off;
title('Average Packet Delay');
xlabel('VoIP flows');
ylabel('Delay (ms)');
legend('Data', 'VoIP');
grid on;

% Create bar chart for packet loss
figure;
hold on;
bar_loss = [pack_loss_data; pack_loss_voip]';
bar_handle = bar(n, bar_loss, 'grouped');
% Adjust error bar positions
x_data = bar_handle(1).XEndPoints;
x_voip = bar_handle(2).XEndPoints;
errorbar(x_data, pack_loss_data, pack_loss_data_inter, 'k', 'linestyle', 'none');
errorbar(x_voip, pack_loss_voip, pack_loss_voip_inter, 'k', 'linestyle', 'none');
hold off;
title('Packet Loss');
xlabel('VoIP flows');
ylabel('Loss (%)');
legend('Data', 'VoIP');
grid on;

%}

% e)

lambda = 1500;
C = 10;
f = 10000;
n = [10,20,30,40];
P = 100000;
p = 60;

N = 20;

param1 = zeros(1,N);
param2 = zeros(1,N);
param3 = zeros(1,N);
param4 = zeros(1,N);

avg_pack_delay_data = zeros(1,4);
avg_pack_delay_inter = zeros(1,4);

pack_loss_data = zeros(1,4);
pack_loss_data_inter = zeros(1,4);

avg_pack_delay_voip = zeros(1,4);
avg_pack_delay_voip_inter = zeros(1,4);

pack_loss_voip = zeros(1,4);
pack_loss_voip_inter = zeros(1,4);

alfa = 0.1;

for idx = 1:length(n)
    for x = 1:N
        [param1(x), param2(x), param3(x), param4(x)]  = Sim4A(lambda,C,f,P,n(idx),p);
    end
    avg_pack_delay_data(idx) = mean(param3);
    avg_pack_delay_inter(idx) = norminv(1-alfa/2)*sqrt(var(param3)/N);

    pack_loss_data(idx) = mean(param1);
    pack_loss_data_inter(idx) = norminv(1-alfa/2)*sqrt(var(param1)/N);

    avg_pack_delay_voip(idx) = mean(param4);
    avg_pack_delay_voip_inter(idx) = norminv(1-alfa/2)*sqrt(var(param4)/N);

    pack_loss_voip(idx) = mean(param2);
    pack_loss_voip_inter(idx) = norminv(1-alfa/2)*sqrt(var(param2)/N);
end


% Create bar chart for average packet delay
figure;
hold on;
bar_data = [avg_pack_delay_data; avg_pack_delay_voip]';
bar_handle = bar(n, bar_data, 'grouped');
% Adjust error bar positions
x_data = bar_handle(1).XEndPoints;
x_voip = bar_handle(2).XEndPoints;
errorbar(x_data, avg_pack_delay_data, avg_pack_delay_inter, 'k', 'linestyle', 'none');
errorbar(x_voip, avg_pack_delay_voip, avg_pack_delay_voip_inter, 'k', 'linestyle', 'none');
hold off;
title('Average Packet Delay');
xlabel('VoIP flows');
ylabel('Delay (ms)');
legend('Data', 'VoIP');
grid on;

% Create bar chart for packet loss
figure;
hold on;
bar_loss = [pack_loss_data; pack_loss_voip]';
bar_handle = bar(n, bar_loss, 'grouped');
% Adjust error bar positions
x_data = bar_handle(1).XEndPoints;
x_voip = bar_handle(2).XEndPoints;
errorbar(x_data, pack_loss_data, pack_loss_data_inter, 'k', 'linestyle', 'none');
errorbar(x_voip, pack_loss_voip, pack_loss_voip_inter, 'k', 'linestyle', 'none');
hold off;
title('Packet Loss');
xlabel('VoIP flows');
ylabel('Loss (%)');
legend('Data', 'VoIP');
grid on;