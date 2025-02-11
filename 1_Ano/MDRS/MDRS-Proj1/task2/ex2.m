%2 a)
fprintf('2 a)\n')
prate = 1500;
C = 10;
f = 1e6;
b = 1e-5;
P = 1e5;
n = [10,20,30,40];
runs = 20;
PLd  = cell(1,length(n));
PLv  = cell(1,length(n));
APDd = cell(1,length(n));
APDv = cell(1,length(n));
MPDd = cell(1,length(n));
MPDv = cell(1,length(n));
TT   = cell(1,length(n));

mean_PLd   = zeros(1,length(n));
mean_PLv   = zeros(1,length(n));
error_PLd  = zeros(1,length(n));
error_PLv  = zeros(1,length(n));

mean_APDd  = zeros(1,length(n));
mean_APDv  = zeros(1,length(n));
error_APDd = zeros(1,length(n));
error_APDv = zeros(1,length(n));

mean_MPDd  = zeros(1,length(n));
mean_MPDv  = zeros(1,length(n));
error_MPDd = zeros(1,length(n));
error_MPDv = zeros(1,length(n));

mean_TT    = zeros(1,length(n));
error_TT   = zeros(1,length(n));

for i= 1:length(n)
    PLd{i}  = zeros(1,runs);
    PLv{i}  = zeros(1,runs);
    APDd{i} = zeros(1,runs);
    APDv{i} = zeros(1,runs);
    MPDd{i} = zeros(1,runs);
    MPDv{i} = zeros(1,runs);
    TT{i}   = zeros(1,runs);
    for it= 1:runs
        [PLd{i}(it), PLv{i}(it), APDd{i}(it), APDv{i}(it), MPDd{i}(it), MPDv{i}(it), TT{i}(it)] = Sim3a(prate,C,f,P,n(i),b);
    end
    fprintf("\n Experience with %d VoIP flows\n", n(i));
    alfa = 0.1;       
    mean_PLd(i) = mean(PLd{i});
    error_PLd(i) = norminv(1-alfa/2)*sqrt(var(PLd{i})/runs);
    fprintf('PacketLoss of data (%%)\t= %.2e +- %.2e\n', mean_PLd(i), error_PLd(i));
    
    mean_PLv(i) = mean(PLv{i});
    error_PLv(i) = norminv(1-alfa/2)*sqrt(var(PLv{i})/runs);
    fprintf('PacketLoss of VoIP(%%)\t= %.2e +- %.2e\n', mean_PLv(i), error_PLv(i));
    
    mean_APDd(i) = mean(APDd{i});
    error_APDd(i) = norminv(1-alfa/2)*sqrt(var(APDd{i})/runs);
    fprintf('Av. Packet Delay of data (ms)\t= %.2e +- %.2e\n', mean_APDd(i), error_APDd(i));
    
    mean_APDv(i) = mean(APDv{i});
    error_APDv(i) = norminv(1-alfa/2)*sqrt(var(APDv{i})/runs);
    fprintf('Av. Packet Delay of VoIP (ms)\t= %.2e +- %.2e\n', mean_APDv(i), error_APDv(i));
    
    mean_MPDd(i) = mean(MPDd{i});
    error_MPDd(i) = norminv(1-alfa/2)*sqrt(var(MPDd{i})/runs);
    fprintf('Max. Packet Delay of data (ms)\t= %.2e +- %.2e\n', mean_MPDd(i), error_MPDd(i));
    
    mean_MPDv(i) = mean(MPDv{i});
    error_MPDv(i) = norminv(1-alfa/2)*sqrt(var(MPDv{i})/runs);
    fprintf('Max. Packet Delay of VoIP (ms)\t= %.2e +- %.2e\n', mean_MPDv(i), error_MPDv(i));
    
    mean_TT(i) = mean(TT{i});
    error_TT(i) = norminv(1-alfa/2)*sqrt(var(TT{i})/runs);
    fprintf('Throughput (Mbps)\t= %.2e +- %.2e\n', mean_TT(i), error_TT(i));

end

%2 b)
fprintf('2 b)\n')

figure;
hold on;

bar_width = 0.35;
x = 1:length(n);

PLdata = bar(x - bar_width/2, mean_PLd, bar_width, 'FaceColor', [0.2, 0.6, 0.8]);
errorbar(x - bar_width/2, mean_PLd, error_PLd, 'k', 'LineStyle', 'none');

PLVoIP = bar(x + bar_width/2, mean_PLv, bar_width, 'FaceColor', [0.8, 0.4, 0.2]);
errorbar(x + bar_width/2, mean_PLv, error_PLv, 'k', 'LineStyle', 'none');

xticks(x);
xticklabels({'10 Flows', '20 Flows', '30 Flows', '40 Flows'});
xlabel('Number of VoIP Flows');
ylabel('Packet Loss (%)');
title('Packet Loss Comparison: Data vs VoIP');
legend([PLdata, PLVoIP], {'PacketLoss of data', 'PacketLoss of VoIP'}, 'Location', 'northeastoutside');
grid on;
hold off;

fprintf("The Packet Loss of Data is Greater than VoIP, Because VoIP is smaller\n")
fprintf("The Packet Loss Intervals stay mostly the same between different flows\n")
fprintf("The confidence intervals become smaller the more flows occur?\n")


%2 c)
fprintf('2 c)\n')

figure;
hold on;

bar_width = 0.35;
x = 1:length(n);

APDdata = bar(x - bar_width/2, mean_APDd, bar_width, 'FaceColor', [0.2, 0.6, 0.8]);
errorbar(x - bar_width/2, mean_APDd, error_APDd, 'k', 'LineStyle', 'none');

APDVoIP = bar(x + bar_width/2, mean_APDv, bar_width, 'FaceColor', [0.8, 0.4, 0.2]);
errorbar(x + bar_width/2, mean_APDv, error_APDv, 'k', 'LineStyle', 'none');

xticks(x);
xticklabels({'10 Flows', '20 Flows', '30 Flows', '40 Flows'});
xlabel('Number of VoIP Flows');
ylabel('Average Packet Delay (ms)');
title('Av. Packet Delay comparison: Data vs VoIP');
legend([APDdata, APDVoIP], {'AV. Packet Delay of data', 'Av. Packet Delay of VoIP'}, 'Location', 'northeastoutside');
grid on;
hold off;


fprintf("The addition of more VoIP fluxes makes the Av. delay across data and VoIP bigger as there are more packets competing for limited resources\n");
fprintf("O atraso médio cresce conforme o aumento dos fluxos VoIP, aumentando severamente no caso dos 40 fluxos\n")



%2 d)
fprintf('2 d)\n')

figure;
hold on;

bar_width = 0.35;
x = 1:length(n);

MPDdata = bar(x - bar_width/2, mean_MPDd, bar_width, 'FaceColor', [0.2, 0.6, 0.8]);
errorbar(x - bar_width/2, mean_MPDd, error_MPDd, 'k', 'LineStyle', 'none');

MPDVoIP = bar(x + bar_width/2, mean_MPDv, bar_width, 'FaceColor', [0.8, 0.4, 0.2]);
errorbar(x + bar_width/2, mean_MPDv, error_MPDv, 'k', 'LineStyle', 'none');

xticks(x);
xticklabels({'10 Flows', '20 Flows', '30 Flows', '40 Flows'});
xlabel('Number of VoIP Flows');
ylabel('Max. Packet Delay (ms)');
title('Max. Packet Delay comparison: Data vs VoIP');
legend([MPDdata, MPDVoIP], {'Max. Packet Delay of Data', 'Max. Packet Delay of VoIP'}, 'Location', 'northeastoutside');
grid on;
hold off;

fprintf("As the number of VoIP flows increase, so does the Max. Packet Delay of both data and VoIP\n")
fprintf("We also see an increase in the error margins as we increse the flows, so the delays fluctuate with increased load")



%2 e)
fprintf('2 e)\n')

figure;
hold on;

bar_width = 0.35;
x = 1:length(n);

TT = bar(x, mean_TT, bar_width, 'FaceColor', [0.2, 0.6, 0.8]);
errorbar(x, mean_TT, error_TT, 'k', 'LineStyle', 'none');

xticks(x);
xticklabels({'10 Flows', '20 Flows', '30 Flows', '40 Flows'});
xlabel('Number of VoIP Flows');
ylabel('Throughput (Mbps)');
title('Throughput comparison with VoIP flows');
legend(TT, {'Throughput'}, 'Location', 'northeastoutside');
grid on;
hold off;

fprintf("The Transmitted Throughput increase linearly throught the increasing VoIP flows\n")
fprintf("The error intervals are low and stay mostly the same")

%2 f)
fprintf('\n2.f)\n');
f = 1e6; 
prate = 1500; 
capacity = 10 * 10^6;
b = 1e-5;

pdata = [0.19, 0.23, 0.17]; 
sizes_data = [64, 110, 1518]; 

prob_left_data = (1 - sum(pdata)) / ((109 - 65 + 1) + (1517 - 111 + 1));
avg_size_data = sum(pdata .* sizes_data);

data_success_prob = sum(pdata .* (1 - b).^(sizes_data * 8)); 

left_packets = [65:109, 111:1517];
avg_size_data = avg_size_data + prob_left_data * sum(left_packets);
data_success_prob = data_success_prob + prob_left_data * sum((1 - b).^(left_packets * 8)); 

avg_size_voip = (110 + 130) / 2;
voip_success_prob = mean((1 - b).^(110:130 * 8));

lambda_voip = 1 / mean([0.016, 0.024]); 

voip_flows = [10, 20, 30, 40];

for i = 1:length(voip_flows)
    num_flows = voip_flows(i);
    throughput_data = (prate * avg_size_data * 8 * data_success_prob) / 1e6; 
    throughput_voip = (lambda_voip * avg_size_voip * 8 * voip_success_prob) / 1e6; 

    total_throughput = throughput_data + (num_flows * throughput_voip); 
    fprintf("Throughput (Mbps) for %d VoIP flows = %.4f\n", num_flows, total_throughput);
end


