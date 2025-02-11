function [PLd, PLv , APDd, APDv , MPDd, MPDv , TT] = Sim4(lambda,C,f,P,n)
% INPUT PARAMETERS:
%  lambda - packet rate (packets/sec)
%  C      - link bandwidth (Mbps)
%  f      - queue size (Bytes)
%  P      - number of packets (stopping criterium)
%  n      - number of VoIP packet flows
% OUTPUT PARAMETERS:
%  PLd   - packet loss of data packets(%)
%  PLv   - packet loss of VoIP packets(%)
%  APDd  - average packet delay of data packets(milliseconds)
%  APDv  - average packet delay of VoIP packets(milliseconds)
%  MPDd  - maximum delay of data packets(milliseconds)
%  MPDv  - maximum delay of VoIP packets(milliseconds)
%  TT   - transmitted throughput (data+VoIP) (Mbps)

%Events:
ARRIVAL= 0;       % Arrival of a packet            
DEPARTURE= 1;     % Departure of a packet

%Packet type
DATA = 0;
VOIP = 1;

%State variables:
STATE = 0;          % 0 - connection is free; 1 - connection is occupied
QUEUEOCCUPATION= 0; % Occupation of the queue (in Bytes)
QUEUE= [];          % Size and arriving time instant of each packet in the queue

%Statistical Counters:
TOTALPACKETSD= 0;     % No. of data packets arrived to the system
TOTALPACKETSV= 0;     % No. of voip packets arrived to the system
LOSTPACKETSD= 0;      % No. of data packets dropped due to buffer overflow
LOSTPACKETSV= 0;      % No. of voip packets dropped due to buffer overflow
TRANSPACKETSD= 0;     % No. of transmitted data packets
TRANSPACKETSV= 0;     % No. of transmitted voip packets
TRANSBYTESD= 0;       % Sum of the Bytes of transmitted data packets
TRANSBYTESV= 0;       % Sum of the Bytes of transmitted voip packets
DELAYSD= 0;           % Sum of the delays of transmitted data packets
DELAYSV= 0;           % Sum of the delays of transmitted voip packets
MAXDELAYD= 0;         % Maximum delay among all transmitted data packets
MAXDELAYV= 0;         % Maximum delay among all transmitted voip packets

% Initializing the simulation clock:
Clock= 0;

% Initializing the List of Events with the first ARRIVAL:
tmp= Clock + exprnd(1/lambda);
EventList = [ARRIVAL, tmp, GeneratePacketSize(), tmp, DATA]; % DATA is used to identify type of packet

%Initializing VoIP packets
for i = 1:n
    tmp = unifrnd(0, 0.02);    % time packet arrivals is uniform distribution between 0 ms and 20 ms
    EventList = [EventList; ARRIVAL, tmp, randi([110, 130]), tmp, VOIP];
end

%Simulation loop:
while (TRANSPACKETSD + TRANSPACKETSV)<P               % Stopping criterium
    EventList= sortrows(EventList,2);  % Order EventList by time
    Event= EventList(1,1);              % Get first event 
    Clock= EventList(1,2);              %    and all
    PacketSize= EventList(1,3);        %    associated
    ArrInstant= EventList(1,4);    %    parameters.
    PacketType = EventList(1,5);
    EventList(1,:)= [];                 % Eliminate first event
    switch Event
        case ARRIVAL         % If first event is an ARRIVAL
            if(PacketType == DATA)
                TOTALPACKETSD= TOTALPACKETSD+1;
                tmp= Clock + exprnd(1/lambda);
                EventList = [EventList; ARRIVAL, tmp, GeneratePacketSize(), tmp,DATA];
                if STATE==0
                    STATE= 1;
                    EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*10^6), PacketSize, Clock,DATA];
                else
                    if QUEUEOCCUPATION + PacketSize <= f
                        QUEUE= [QUEUE;PacketSize , Clock, DATA];
                        QUEUEOCCUPATION= QUEUEOCCUPATION + PacketSize;
                    else
                        LOSTPACKETSD= LOSTPACKETSD + 1;
                    end
                end
            else % PacketType == VoIP
                TOTALPACKETSV= TOTALPACKETSV+1;
                tmp= Clock + unifrnd(0.016, 0.024); 
                EventList = [EventList; ARRIVAL, tmp, randi([110,130]), tmp,VOIP];
                if STATE==0
                    STATE= 1;
                    EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*10^6), PacketSize, Clock,VOIP];
                else
                    if QUEUEOCCUPATION + PacketSize <= f
                        QUEUE= [QUEUE;PacketSize , Clock, VOIP];
                        QUEUEOCCUPATION= QUEUEOCCUPATION + PacketSize;
                    else
                        LOSTPACKETSV= LOSTPACKETSV + 1;
                    end
                end
            end
        case DEPARTURE          % If first event is a DEPARTURE
            if(PacketType == DATA)
                TRANSBYTESD= TRANSBYTESD + PacketSize;
                DELAYSD= DELAYSD + (Clock - ArrInstant);
                if Clock - ArrInstant > MAXDELAYD
                    MAXDELAYD= Clock - ArrInstant;
                end
                TRANSPACKETSD= TRANSPACKETSD + 1;
            else
                TRANSBYTESV= TRANSBYTESV + PacketSize;
                DELAYSV= DELAYSV + (Clock - ArrInstant);
                if Clock - ArrInstant > MAXDELAYV
                    MAXDELAYV= Clock - ArrInstant;
                end
                TRANSPACKETSV= TRANSPACKETSV + 1;
            end

            if QUEUEOCCUPATION > 0
                QUEUE = sortrows(QUEUE,3,"descend"); % voip packets will be the first to be removed from the queue
                EventList = [EventList; DEPARTURE, Clock + 8*QUEUE(1,1)/(C*10^6), QUEUE(1,1), QUEUE(1,2), QUEUE(1,3)]; %QUEUE(1,3) is the type of packet
                QUEUEOCCUPATION= QUEUEOCCUPATION - QUEUE(1,1);
                QUEUE(1,:)= [];
            else
                STATE= 0;
            end
    end
end

%Performance parameters determination:
PLd= 100*LOSTPACKETSD/TOTALPACKETSD;  % in percentage
PLv= 100*LOSTPACKETSV/TOTALPACKETSV;  % in percentage
APDd= 1000*DELAYSD/TRANSPACKETSD;     % in milliseconds
APDv= 1000*DELAYSV/TRANSPACKETSV;     % in milliseconds
MPDd= 1000*MAXDELAYD;                % in milliseconds
MPDv= 1000*MAXDELAYV;                % in milliseconds
TT= 1e-6*(TRANSBYTESD + TRANSBYTESV)*8/Clock;    % in Mbps

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
