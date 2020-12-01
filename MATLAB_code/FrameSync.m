%function [SynchronizedOutput] =  FrameSync(OriginalDataInput)

%script form, for testing
OriginalDataInput = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];

flag = 0; % when the flag from 0 to 1, it means find the start of frame
N = 0;
L = 16; % the length of delay point
L2 = 48; % the length of second stage ram
Counter = 1; % the index of input sequence, like the clock in the hardware circuit
FirstOrderShiftRam = zeros(1,L);
SecondOrderShitRam = zeros(1,L2);
DataIn = 0;
OriginalDataInput = [zeros(1,L+L2),OriginalDataInput,zeros(1,1)]; % simulate the spare time before effective information
CorrelatedSTSRam = zeros(1,L);
CorrelatedOriRam = zeros(1,L);
CorrelatedSum = 0;
CorrelatedOriSum = 0;
RatioOutputArray = zeros(1,length(OriginalDataInput));
while(~flag)
	% using the software to simulation hardware circuit 
	DataInMSB = DataIn;
	DataIn = OriginalDataInput(Counter);
	FirstOrderShiftRamMSB = FirstOrderShiftRam(L);
	FirstOrderShiftRam = [DataInMSB,FirstOrderShiftRam(1:L-1)];
	SecondOrderShiftRamMSB = SecondOrderShitRam(L2);
	SecondOrderShitRam = [FirstOrderShiftRamMSB,SecondOrderShitRam(1:L2-1)];
	CorrelatedSTS = DataInMSB * (FirstOrderShiftRamMSB');
	CorrelatedSTSRamMSB = CorrelatedSTSRam(L);
	CorrelatedSTSRam = [CorrelatedSTS,CorrelatedSTSRam(1:L-1)];
	CorrelatedSum = CorrelatedSum + CorrelatedSTS - CorrelatedSTSRamMSB;
	CorrelatedOri = DataInMSB*(DataInMSB');
	CorrelatedOriRamMSB = CorrelatedOriRam(L);
	CorrelatedOriRam = [CorrelatedOri,CorrelatedOriRam(1:L-1)];
	CorrelatedOriSum = CorrelatedOriSum + CorrelatedOri - CorrelatedOriRamMSB;
    RatioOutput = abs(CorrelatedSum)/CorrelatedOriSum;
    RatioOutputArray(Counter) = RatioOutput;
    Counter = Counter + 1;
    if(RatioOutput == 1)
        break;
    end
end
plot(RatioOutputArray);



