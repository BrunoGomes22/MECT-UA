%% ex3
% a) e b) processos de nascimento e morte
% lambda taxa de chegada ->
% u taxa de morte <-

% prob 10^-6

den = 1 + 8/600 + (8/600 * 5/100) + (8/600 * 5/100 * 2/20) + (8/600 * 5/100 * 2/20 * 1/5);

e0 = 1/den;
e0

% prob 10^-5

e1  = (8/600) / den;
e1

% prob 10^-4

e2  = ((8/600)*(5/100)) / den;
e2

% prob 10^-3

e3 = ((8/600)*(5/100)*(2/20)) / den;
e3

% prob 10^-2

e4 = ((8/600)*(5/100)*(2/20)*(1/5)) / den;
e4

% c) sum(prob_estado * estado) -> média de var. aleatoria discreta

avg_ber = (1e-6 * e0 + 1e-5 * e1 + 1e-4 * e2 + 1e-3 * e3 + 1e-2 * e4);
avg_ber

% d) Tempo medio de permanencia T = 1/qi;
% qi = transicao de saida

avg_time_e0 = (1/8)*60;
fprintf("Average time in minutes that the links stays in state 10e-6: %2.1f min\n" ,avg_time_e0);

avg_time_e1 = (1/(600+5))*60;
fprintf("Average time in minutes that the links stays in state 10e-5: %2.1f min\n" ,avg_time_e1);

avg_time_e2 = (1/(100+2))*60;
fprintf("Average time in minutes that the links stays in state 10e-4: %2.1f min\n" ,avg_time_e2);

avg_time_e3 = (1/(20+1))*60;
fprintf("Average time in minutes that the links stays in state 10e-3: %2.1f min\n" ,avg_time_e3);

avg_time_e4 = (1/5)*60;
fprintf("Average time in minutes that the links stays in state 10e-2: %2.1f min\n" ,avg_time_e4);

% e) estado normal < 10^-3; 
%    estado interferencia >= 10^-3;
% como os eventos sao mutualmente exclusivos podemos somar as
% probabilidades

prob_interference_state = e3 + e4;
prob_interference_state

prob_normal_state = e0 + e1 + e2 + e3;
prob_normal_state

% f)

avg_ber_interference = ((1e-3 * e3) + (1e-2 * e4))/prob_interference_state;
fprintf("Average BER in interference state: %.2e\n", avg_ber_interference);

avg_ber_normal = ((1e-6 * e0) + (1e-5 * e1) + (1e-4 * e2))/prob_normal_state;
fprintf("Average BER in interference state: %.2e\n", avg_ber_normal);

% g)
ber_aux = [1e-6, 1e-5, 1e-4, 1e-3, 1e-2];

den = [1, 8/600, 8/600*5/100, 8/600*5/100*2/20, 8/600*5/100*2/20*1/5];

p = den/sum(den);

x = 64:1500;

s1 = 1 - (1 - ber_aux(1)).^(x*8);
s2 = 1 - (1 - ber_aux(2)).^(x*8);
s3 = 1 - (1 - ber_aux(3)).^(x*8);
s4 = 1 - (1 - ber_aux(4)).^(x*8);
s5 = 1 - (1 - ber_aux(5)).^(x*8);

prob = s1*p(1)+s2*p(2)+s3*p(3)+s4*p(4)+s5*p(5);

figure(1);
plot(x,prob)
xlabel("B (Bytes)")
title("Prob. of at least one error")
grid on


% h) P(N|E) = P(NE)/P(E)
%   P(N|E) = (P(E|e0).P(e0) + P(E|e1).P(e1) + P(E|e2).P(e2))/ P(E)
%   P(E) = P(E|e0).P(e0) + P(E|e1).P(e1) + P(E|e2).P(e2) + P(E|e3).P(e3) + P(E|e4).P(e4)
%   E -> at least one error
%   N -> being in the normal state

p_error_state1 = 1 - (1 - ber_aux(1)).^(x*8);
p_error_state2 = 1 - (1 - ber_aux(2)).^(x*8);
p_error_state3 = 1 - (1 - ber_aux(3)).^(x*8);
p_error_state4 = 1 - (1 - ber_aux(4)).^(x*8);
p_error_state5 = 1 - (1 - ber_aux(5)).^(x*8);

prob_err_normal = (e0 .* p_error_state1 + e1 .* p_error_state2 + e2 .* p_error_state3)./(e0 .* p_error_state1 + e1 .* p_error_state2 + e2 .* p_error_state3 + e3 .* p_error_state4 + e4 .* p_error_state5);

figure(2);
plot(x, prob_err_normal)
xlabel("B (Bytes)")
title("Prob. of Normal State")
grid on

% i)
%   P(I|~E) = P(I~E)/P(~E)
%   P(I|~E) = (P(~E|e3).P(e3) + P(~E|e4).P(e4))/ P(~E)
%   P(~E) = P(~E|e0).P(e0) + P(~E|e1).P(e1) + P(~E|e2).P(e2) + P(~E|e3).P(e3) + P(~E|e4).P(e4)
%   I  -> being in the interference state
%   ~E -> no errors

p_noerror_state1 = (1 - ber_aux(1)).^(x*8);
p_noerror_state2 = (1 - ber_aux(2)).^(x*8);
p_noerror_state3 = (1 - ber_aux(3)).^(x*8);
p_noerror_state4 = (1 - ber_aux(4)).^(x*8);
p_noerror_state5 = (1 - ber_aux(5)).^(x*8);

prob_noerror_int = (p_noerror_state4 .* e3 + p_noerror_state5 .* e4)./(e0 .* p_noerror_state1 + e1 .* p_noerror_state2 + e2 .* p_noerror_state3 + e3 .* p_noerror_state4 + e4 .* p_noerror_state5);

figure(3);
semilogy(x,prob_noerror_int)
xlabel("B (Bytes)")
title("Prob. of Interference State")
grid on