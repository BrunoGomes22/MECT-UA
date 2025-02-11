function [PLdata, PLVoIP, APDdata , APDVoIP, MPDdata , MPDVoIP, TT] = Sim3a(lambda,C,f,P,n,b)
% INPUT PARAMETERS:
%  lambda - packet rate (packets/sec)
%  C      - link bandwidth (Mbps)
%  f      - queue size (Bytes)
%  P      - number of packets (stopping criterium)
%  n      - VoIP
%  b      - bit error rate
% OUTPUT PARAMETERS:
%  PLdata - Packet Loss of data packets (%)
%  PLVoIP − Packet Loss of VoIP packets (%)
%  APDdata  -Average Delay of data packets (milliseconds)
%  APDVoIP − Average Delay of VoIP packets (milliseconds)
%  MPDdata − Maximum Delay of data packets (milliseconds)
%  MPDVoIP − Maximum Delay of VoIP packets (milliseconds)
%  TT − Transmitted Throughput (data + VoIP) (Mbps)

%Packet type
DATA = 0;
VOIP = 1;

%Events:
ARRIVAL= 0;       % Arrival of a packet            
DEPARTURE= 1;     % Departure of a packet

%State variables:
STATE = 0;          % 0 - connection is free; 1 - connection is occupied
QUEUEOCCUPATION= 0; % Occupation of the queue (in Bytes)
QUEUE= [];          % Size and arriving time instant of each packet in the queue    

%Statistical Counters:
TOTALPACKETSD= 0;     % No. of data packets arrived to the system
TOTALPACKETSVP= 0;     % No. of VoIP packets arrived to the system
LOSTPACKETSD= 0;      % No. of data packets dropped due to buffer overflow
LOSTPACKETSVP= 0;      % No. of VoIP packets dropped due to buffer overflow
TRANSPACKETSD= 0;     % No. of transmitted data packets
TRANSPACKETSVP= 0;     % No. of transmitted VoIP packets
TRANSBYTESD= 0;       % Sum of the Bytes of transmitted data packets
TRANSBYTESVP= 0;       % Sum of the Bytes of transmitted VoIP packets
DELAYSD= 0;           % Sum of the delays of transmitted data packets
DELAYSVP= 0;           % Sum of the delays of transmitted VoIP packets
MAXDELAYD= 0;         % Maximum delay among all transmitted data packets
MAXDELAYVP= 0;         % Maximum delay among all transmitted VoIP packets


% Initializing the simulation clock:
Clock= 0;

% Initializing the List of Events with the first ARRIVAL:
tmp= Clock + exprnd(1/lambda);
EventList = [ARRIVAL, tmp, GeneratePacketSize(), tmp, DATA];

%Initialize n VoIP packets
for i = 1:n
    tmp= unifrnd(0, 0.02);
    EventList = [EventList; ARRIVAL, tmp, randi([110,130]), tmp, VOIP];
end

%Similation loop:
while (TOTALPACKETSD + TOTALPACKETSVP) <P    % Stopping criterium
    EventList= sortrows(EventList,2);  % Order EventList by time
    Event= EventList(1,1);              % Get first event 
    Clock= EventList(1,2);              %    and all
    PacketSize= EventList(1,3);        %    associated
    ArrInstant= EventList(1,4);    %    parameters.
    PacketType= EventList(1,5);    % data or VoIP
    EventList(1,:)= [];                 % Eliminate first event
    switch Event
        case ARRIVAL         % If first event is an ARRIVAL
            if(PacketType == DATA)
                TOTALPACKETSD= TOTALPACKETSD+1;
                tmp= Clock + exprnd(1/lambda);
                EventList = [EventList; ARRIVAL, tmp, GeneratePacketSize(), tmp, DATA];
                if STATE==0
                    STATE= 1;
                    EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*10^6), PacketSize, Clock, DATA];
                else
                    if QUEUEOCCUPATION + PacketSize <= f
                        QUEUE= [QUEUE;PacketSize , Clock, DATA];
                        QUEUEOCCUPATION= QUEUEOCCUPATION + PacketSize;
                    else
                        LOSTPACKETSD= LOSTPACKETSD + 1;
                    end
                end
            else  %VoIP
                TOTALPACKETSVP= TOTALPACKETSVP+1;
                tmp= Clock + unifrnd(0.016, 0.024);
                EventList = [EventList; ARRIVAL, tmp, randi([110,130]), tmp, VOIP];
                if STATE==0
                    STATE= 1;
                    EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*10^6), PacketSize, Clock, VOIP];
                else
                    if QUEUEOCCUPATION + PacketSize <= f
                        QUEUE= [QUEUE;PacketSize , Clock, VOIP];
                        QUEUEOCCUPATION= QUEUEOCCUPATION + PacketSize;
                    else
                        LOSTPACKETSVP= LOSTPACKETSVP + 1;
                    end
                end
            end
        case DEPARTURE          % If first event is a DEPARTURE
            if(rand() < (1-b)^(PacketSize*8))
                if(PacketType == DATA)
                    TRANSBYTESD= TRANSBYTESD + PacketSize;
                    DELAYSD= DELAYSD + (Clock - ArrInstant);
                    if Clock - ArrInstant > MAXDELAYD
                        MAXDELAYD= Clock - ArrInstant;
                    end
                    TRANSPACKETSD= TRANSPACKETSD + 1;
                else %VoIP
                    TRANSBYTESVP= TRANSBYTESVP + PacketSize;
                    DELAYSVP= DELAYSVP + (Clock - ArrInstant);
                    if Clock - ArrInstant > MAXDELAYVP
                        MAXDELAYVP= Clock - ArrInstant;
                    end
                    TRANSPACKETSVP= TRANSPACKETSVP + 1;
                end
            else
                if(PacketType == DATA)
                    LOSTPACKETSD = LOSTPACKETSD + 1;
                else
                    LOSTPACKETSVP = LOSTPACKETSVP + 1;
                end
            end
            if QUEUEOCCUPATION > 0
                EventList = [EventList; DEPARTURE, Clock + 8*QUEUE(1,1)/(C*10^6), QUEUE(1,1), QUEUE(1,2), QUEUE(1,3)];%packet type
                QUEUEOCCUPATION= QUEUEOCCUPATION - QUEUE(1,1);
                QUEUE(1,:)= [];
            else
                STATE= 0;
            end
    end
end

%Performance parameters determination:
PLdata= 100*LOSTPACKETSD/TOTALPACKETSD;         % in percentage
PLVoIP= 100*LOSTPACKETSVP/TOTALPACKETSVP;       % in percentage
APDdata= 1000*DELAYSD/TRANSPACKETSD;            % in milliseconds
APDVoIP= 1000*DELAYSVP/TRANSPACKETSVP;          % in milliseconds
MPDdata= 1000*MAXDELAYD;                        % in milliseconds
MPDVoIP= 1000*MAXDELAYVP;                       % in miliseconds
TT= 1e-6*(TRANSBYTESVP + TRANSBYTESD)*8/Clock;  % in Mbps

end

function out= GeneratePacketSize()
    aux= rand();
    aux2= [65:109 111:1517];
    if aux <= 0.19
        out= 64;
    elseif aux <= 0.19 + 0.23
        out= 110;
    elseif aux <= 0.19 + 0.23 + 0.17
        out= 1518;
    else
        out = aux2(randi(length(aux2)));
    end
end