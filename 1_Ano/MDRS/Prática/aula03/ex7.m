%% 7
% b)



lambda = 1800;         %packet rate (packets/sec)
C = 10;                %link bandwidth (Mbps)
f = 1000000;           %queue size (Bytes)
P = 10000;             %number of packets (stopping criterium)
n = 20;                % number of voip packet flows

N = 100;

param1 = zeros(1,N);
param2 = zeros(1,N);
param3 = zeros(1,N);
param4 = zeros(1,N);
param5 = zeros(1,N);
param6 = zeros(1,N);
param7 = zeros(1,N);

%{

fprintf("----Sim3 running for 100 times, with f=1000000 bytes----\n");

for x = 1:N
  [param1(x), param2(x), param3(x), param4(x), param5(x), param6(x), param7(x)]  = Sim3(lambda,C,f,P,n);
end

alfa = 0.1; % 90% confidence interval
media = mean(param1);
term = norminv(1-alfa/2)*sqrt(var(param1)/N);
fprintf('PacketLoss of data (%%) = %.2e +- %.2e\n',media,term)
media = mean(param2);
term = norminv(1-alfa/2)*sqrt(var(param2)/N);
fprintf('PacketLoss of VoIP (%%) = %.2e +- %.2e\n',media,term)
media = mean(param3);
term = norminv(1-alfa/2)*sqrt(var(param3)/N);
fprintf('Av. Packet Delay of data (ms) = %.2e +- %.2e\n',media,term)
media = mean(param4);
term = norminv(1-alfa/2)*sqrt(var(param4)/N);
fprintf('Av. Packet Delay of VoIP (ms) = %.2e +- %.2e\n',media,term)
media = mean(param5);
term = norminv(1-alfa/2)*sqrt(var(param5)/N);
fprintf('Max. Packet Delay of data (ms) = %.2e +- %.2e\n',media,term)
media = mean(param6);
term = norminv(1-alfa/2)*sqrt(var(param6)/N);
fprintf('Max. Packet Delay of VoIP (ms) = %.2e +- %.2e\n',media,term)
media = mean(param7);
term = norminv(1-alfa/2)*sqrt(var(param7)/N);
fprintf('Throughput (Mbps) = %.2e +- %.2e\n',media,term)




%c)

fprintf("-----Sim3 running for 100 times, with f=10000 bytes-----\n");

f = 10000;

for x = 1:N
  [param1(x), param2(x), param3(x), param4(x), param5(x), param6(x), param7(x)]  = Sim3(lambda,C,f,P,n);
end

alfa = 0.1; % 90% confidence interval
media = mean(param1);
term = norminv(1-alfa/2)*sqrt(var(param1)/N);
fprintf('PacketLoss of data (%%) = %.2e +- %.2e\n',media,term)
media = mean(param2);
term = norminv(1-alfa/2)*sqrt(var(param2)/N);
fprintf('PacketLoss of VoIP (%%) = %.2e +- %.2e\n',media,term)
media = mean(param3);
term = norminv(1-alfa/2)*sqrt(var(param3)/N);
fprintf('Av. Packet Delay of data (ms) = %.2e +- %.2e\n',media,term)
media = mean(param4);
term = norminv(1-alfa/2)*sqrt(var(param4)/N);
fprintf('Av. Packet Delay of VoIP (ms) = %.2e +- %.2e\n',media,term)
media = mean(param5);
term = norminv(1-alfa/2)*sqrt(var(param5)/N);
fprintf('Max. Packet Delay of data (ms) = %.2e +- %.2e\n',media,term)
media = mean(param6);
term = norminv(1-alfa/2)*sqrt(var(param6)/N);
fprintf('Max. Packet Delay of VoIP (ms) = %.2e +- %.2e\n',media,term)
media = mean(param7);
term = norminv(1-alfa/2)*sqrt(var(param7)/N);
fprintf('Throughput (Mbps) = %.2e +- %.2e\n',media,term)

% comparando estes resultados com os resultados obtidos na experiência 7.b
% vemos que ao diminuir a tamanho da fila de espera de 1.000.000 de bytes
% para 10.000 bytes, o parâmetro da perda de pacotes aumenta drasticamente
% tanto nos pacotes VoIP como também nos pacotes de dados, no entanto
% perdem-se mais pacotes de dados do que pacotes VoIP, isto deve-se ao
% facto de os pacotes de dados na sua grande maioria possuirem maior
% tamanho que os pacotes VoIP, como ambos os fluxos seguem a disciplina de
% armazenamento FIFO, os pacotes de menor dimensão vão ter mais facilidade
% a entrar no FIFO que os pacotes de maior dimensão, pois estes entram na
% mesma assim que apareça o minimo espaço disponivel na fila. Isto vai
% fazer com que os pacotes de maior tamanho sejam mais propensos a serem
% descartados por não terem espaço suficente na fila.
% Adicionalmente, como os pacotes de dados vão ter maior dificuldade a
% entrar na fila, estes vão ficando cada vez mais atrasados á medida que o
% tráfego da rede aumenta,
% aumentando assim o atraso de cada pacote, que por sua vez faz com que
% o atraso médio do fluxo de dados aumente. A ligeira diferença no atraso
% médio dos pacotes do fluxo de dados em relação ao fluxos de VoIP deve-se
% ao fator dos pacotes VoIP sofrerem menos atrasos que os pacotes de dados(porque são usualmente menores).
% O max packet delay é maior no fluxo de dados pelas razões descritas
% acima.
% Por fim, o throughput é menor nesta experiência porque foram perdidos
% pacotes no fluxo de dados e nos fluxos VoIP.

%}



% d)

fprintf("-----Sim3 running for 100 times, with f=2000 bytes-----\n");

f = 2000;

for x = 1:N
  [param1(x), param2(x), param3(x), param4(x), param5(x), param6(x), param7(x)]  = Sim3(lambda,C,f,P,n);
end

alfa = 0.1; % 90% confidence interval
media = mean(param1);
term = norminv(1-alfa/2)*sqrt(var(param1)/N);
fprintf('PacketLoss of data (%%) = %.2e +- %.2e\n',media,term)
media = mean(param2);
term = norminv(1-alfa/2)*sqrt(var(param2)/N);
fprintf('PacketLoss of VoIP (%%) = %.2e +- %.2e\n',media,term)
media = mean(param3);
term = norminv(1-alfa/2)*sqrt(var(param3)/N);
fprintf('Av. Packet Delay of data (ms) = %.2e +- %.2e\n',media,term)
media = mean(param4);
term = norminv(1-alfa/2)*sqrt(var(param4)/N);
fprintf('Av. Packet Delay of VoIP (ms) = %.2e +- %.2e\n',media,term)
media = mean(param5);
term = norminv(1-alfa/2)*sqrt(var(param5)/N);
fprintf('Max. Packet Delay of data (ms) = %.2e +- %.2e\n',media,term)
media = mean(param6);
term = norminv(1-alfa/2)*sqrt(var(param6)/N);
fprintf('Max. Packet Delay of VoIP (ms) = %.2e +- %.2e\n',media,term)
media = mean(param7);
term = norminv(1-alfa/2)*sqrt(var(param7)/N);
fprintf('Throughput (Mbps) = %.2e +- %.2e\n',media,term)

% nesta simulação como a dimensão da fila de espera foi diminuida para 2000
% bytes, preveu-se que mais pacotes iriam ser perdidos, sendo os pacotes de
% dados sempre mais penalizados, o atraso que os pacotes sofrem na fila de
% espera foi reduzido substancialmente porque como a fila agora é menor, os
% os últimos pacotes que estão na fila sofrem menos atrasos do que se
% estivessem numa fila de 10kbytes, ou seja passam menos tempo na fila
% porque esta alberga menos pacotes, sendo o atraso dos pacotes de dados
% sempre superior ao pacotes de VoIP devido á dificuldade de entrada na
% fila. O througput diminui ainda mais porque se perdem ainda mais pacotes
% comparando com as simulações 7.b e 7.c

%{

% e)

lambda = 1800;         %packet rate (packets/sec)
C = 10;                %link bandwidth (Mbps)
f = 1000000;           %queue size (Bytes)
P = 10000;             %number of packets (stopping criterium)
n = 20;                % number of voip packet flows

N = 100;

param1 = zeros(1,N);
param2 = zeros(1,N);
param3 = zeros(1,N);
param4 = zeros(1,N);
param5 = zeros(1,N);
param6 = zeros(1,N);
param7 = zeros(1,N);


fprintf("----Sim4 running for 100 times, with f=1000000 bytes----\n");

for x = 1:N
  [param1(x), param2(x), param3(x), param4(x), param5(x), param6(x), param7(x)]  = Sim4(lambda,C,f,P,n);
end

alfa = 0.1; % 90% confidence interval
media = mean(param1);
term = norminv(1-alfa/2)*sqrt(var(param1)/N);
fprintf('PacketLoss of data (%%) = %.2e +- %.2e\n',media,term)
media = mean(param2);
term = norminv(1-alfa/2)*sqrt(var(param2)/N);
fprintf('PacketLoss of VoIP (%%) = %.2e +- %.2e\n',media,term)
media = mean(param3);
term = norminv(1-alfa/2)*sqrt(var(param3)/N);
fprintf('Av. Packet Delay of data (ms) = %.2e +- %.2e\n',media,term)
media = mean(param4);
term = norminv(1-alfa/2)*sqrt(var(param4)/N);
fprintf('Av. Packet Delay of VoIP (ms) = %.2e +- %.2e\n',media,term)
media = mean(param5);
term = norminv(1-alfa/2)*sqrt(var(param5)/N);
fprintf('Max. Packet Delay of data (ms) = %.2e +- %.2e\n',media,term)
media = mean(param6);
term = norminv(1-alfa/2)*sqrt(var(param6)/N);
fprintf('Max. Packet Delay of VoIP (ms) = %.2e +- %.2e\n',media,term)
media = mean(param7);
term = norminv(1-alfa/2)*sqrt(var(param7)/N);
fprintf('Throughput (Mbps) = %.2e +- %.2e\n',media,term)

% comparando este resultados com os resultados do 7.b, vimos que  os
% atrasos do pacotes de dados aumentaram substancialmente e os atrasos dos
% pacoes VoIP diminuiram bastante, isto deve-se ao facto de os pacotes VoIP
% terem mais prioridade que os pacotes de dados, isto é feito no final de
% cada ciclo da simulação em que os pacotes VoIP presentes na queue são
% organizados de forma decrescente de forma a ficarem posicionados nas
% primeiras posiçoes da fila para serem retirados mais rapidamente da
% mesma, ora isto faz com que os pacotes de dados fiquem on hold bastante
% tempo porque enquanto existerem pacotes VoIP na fila, os pacotes de dados
% nunca serão transmitidos aumentado assim ainda mais o atraso que este
% sofrem na transmissão. O max packet delay para os pacotes de dados fica
% igual pois o tamanho da fila permite mitigar o congestionamento da mesma,
% o max packet delay dos pacotes VoIP diminui pelas razões já descritas
% acima.



% f)

f = 10000;

fprintf("----Sim4 running for 100 times, with f=10000 bytes----\n");

for x = 1:N
  [param1(x), param2(x), param3(x), param4(x), param5(x), param6(x), param7(x)]  = Sim4(lambda,C,f,P,n);
end

alfa = 0.1; % 90% confidence interval
media = mean(param1);
term = norminv(1-alfa/2)*sqrt(var(param1)/N);
fprintf('PacketLoss of data (%%) = %.2e +- %.2e\n',media,term)
media = mean(param2);
term = norminv(1-alfa/2)*sqrt(var(param2)/N);
fprintf('PacketLoss of VoIP (%%) = %.2e +- %.2e\n',media,term)
media = mean(param3);
term = norminv(1-alfa/2)*sqrt(var(param3)/N);
fprintf('Av. Packet Delay of data (ms) = %.2e +- %.2e\n',media,term)
media = mean(param4);
term = norminv(1-alfa/2)*sqrt(var(param4)/N);
fprintf('Av. Packet Delay of VoIP (ms) = %.2e +- %.2e\n',media,term)
media = mean(param5);
term = norminv(1-alfa/2)*sqrt(var(param5)/N);
fprintf('Max. Packet Delay of data (ms) = %.2e +- %.2e\n',media,term)
media = mean(param6);
term = norminv(1-alfa/2)*sqrt(var(param6)/N);
fprintf('Max. Packet Delay of VoIP (ms) = %.2e +- %.2e\n',media,term)
media = mean(param7);
term = norminv(1-alfa/2)*sqrt(var(param7)/N);
fprintf('Throughput (Mbps) = %.2e +- %.2e\n',media,term)

% a perda de pacotes de dados nao se altera muito com a diminuiçao do
% tamanho da fila, isto deve-se ao facto de a queue ainda ter espaço
% suficiente de forma a não se congestionar facilmente com os pacotes de
% dados e VoIP, adicionalmente a largura de banda da ligação também
% é suficientemente grande para não ocorrem congestionamentos frequentes.
% Mesmo tendo prioridade na fila de espera, os pacotes VoIP têm uma taxa de
% chegada menor que os pacotes de dados, o que faz com que o packet loss
% dos pacotes de dados não seja muito penalizada.
% Nesta simulação o packet loss dos dados VoIP diminui ligeiramente devido
% á prioridade que estes têm na fila.
% O max. packet delay aumenta substancialmente nesta simulação deviado á
% diminuição da fila e pelo facto de o pacotes VoIP terem mais prioridade,
% isto faz com que a a fila possa encher mais rapidamente de pacotes VoIP
% causando assim um grande a atraso nos pacotes de dados. O max packet
% delay de dados VoIP diminuiu bastante pela razões descritas acima.
% Throughput manteve-se

%}

% g)

f = 2000;

fprintf("----Sim4 running for 100 times, with f=2000 bytes----\n");

for x = 1:N
  [param1(x), param2(x), param3(x), param4(x), param5(x), param6(x), param7(x)]  = Sim4(lambda,C,f,P,n);
end

alfa = 0.1; % 90% confidence interval
media = mean(param1);
term = norminv(1-alfa/2)*sqrt(var(param1)/N);
fprintf('PacketLoss of data (%%) = %.2e +- %.2e\n',media,term)
media = mean(param2);
term = norminv(1-alfa/2)*sqrt(var(param2)/N);
fprintf('PacketLoss of VoIP (%%) = %.2e +- %.2e\n',media,term)
media = mean(param3);
term = norminv(1-alfa/2)*sqrt(var(param3)/N);
fprintf('Av. Packet Delay of data (ms) = %.2e +- %.2e\n',media,term)
media = mean(param4);
term = norminv(1-alfa/2)*sqrt(var(param4)/N);
fprintf('Av. Packet Delay of VoIP (ms) = %.2e +- %.2e\n',media,term)
media = mean(param5);
term = norminv(1-alfa/2)*sqrt(var(param5)/N);
fprintf('Max. Packet Delay of data (ms) = %.2e +- %.2e\n',media,term)
media = mean(param6);
term = norminv(1-alfa/2)*sqrt(var(param6)/N);
fprintf('Max. Packet Delay of VoIP (ms) = %.2e +- %.2e\n',media,term)
media = mean(param7);
term = norminv(1-alfa/2)*sqrt(var(param7)/N);
fprintf('Throughput (Mbps) = %.2e +- %.2e\n',media,term)

% a perda de pacotes de dados é igual em ambas as simulações, a perda de
% pacotes de VoIP é menor nesta simulação devido á prioridade dada a estes
% pacotes. o atraso medio dos pacotes de dados aumentou porque para além de
% terem mais dificuldade a entrar na fila de espera (por serem pacotes maior que os pacotes VoIP) ainda têm de lidar com
% o facto dos pacotes VoIP serem sempre atendidos primeiro que eles,
% aumentando assim a dificuldade de entrada e atendimento na fila, o que vai fazer com
% que o tempo que um pacote de dados demore a ser transmitido seja superior
% max packet delay dos dados aumenta e max packet delay de pacotes VoIP
% dimuni pelas razões descritas acima.
% throughput é igual