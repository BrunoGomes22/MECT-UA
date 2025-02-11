range_probs = (1 - (0.19 + 0.23 + 0.17))/(109-65+1 + 1517-111+1);

x = 64:1518;

pack_loss = zeros(1,2); % BER = 10^-4 and BER = 10^-6 respectively

j = 1;

for i = 64:1518
    if i == 64
        pack_loss(j) = pack_loss(j) + (1-nchoosek(64*8,0)*((10^-4)^0)*(1-(10^-4))^(64*8)) * 0.19;
        pack_loss(j+1) = pack_loss(j+1) + (1-nchoosek(64*8,0)*((10^-6)^0)*(1-(10^-6))^(64*8)) * 0.19;
            
    elseif i == 110
        pack_loss(j) = pack_loss(j) + (1-nchoosek(110*8,0)*((10^-4)^0)*(1-(10^-4))^(110*8)) * 0.23;
        pack_loss(j+1) = pack_loss(j+1) + (1-nchoosek(110*8,0)*((10^-6)^0)*(1-(10^-6))^(110*8)) * 0.23;
            
    elseif i == 1518
        pack_loss(j) = pack_loss(j) + (1-nchoosek(1518*8,0)*((10^-4)^0)*(1-(10^-4))^(1518*8)) * 0.17;
        pack_loss(j+1) = pack_loss(j+1) + (1-nchoosek(1518*8,0)*((10^-6)^0)*(1-(10^-6))^(1518*8)) * 0.17;
            
    else
        pack_loss(j) = pack_loss(j) + (1-nchoosek(i*8,0)*((10^-4)^0)*(1-(10^-4))^(i*8)) * range_probs;
        pack_loss(j+1) = pack_loss(j+1) + (1-nchoosek(i*8,0)*((10^-6)^0)*(1-(10^-6))^(i*8)) * range_probs;
    end
end

pack_loss = (pack_loss ./ (0.19 + 0.23 + 0.17 + ((109 - 65 + 1) + (1517 - 111 + 1)) * range_probs)) * 100;

fprintf("Theoretical packet loss for BER 10^-4 is %2.1f%%\nTheoretical packet loss for BER 10^-6 is %2.1f%%\n", pack_loss(1),pack_loss(2));