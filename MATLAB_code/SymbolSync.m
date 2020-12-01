function [Counter,SymbolSyncOutput] = SymbolSync(FrameSyncOutput,N,Ncp,FRAME_NUM,RepeatTime)

if N  < 128
	L = 128;
else
	L = N;
end

if N ==1
	ThresholdValue = 40;
else
	ThresholdValue = 2*L-100;
end
Length = length(FrameSyncOutput);
if N ==1
	[~,~,PreambleRam] = PreambleGen(N,Ncp,RepeatTime);
else
	[~,PreambleRam,~] = PreambleGen(N,Ncp,RepeatTime);
end

PreambleRamReal = real(PreambleRam);
PreambleRamImag = imag(PreambleRam);
PreambleRamQuan = complex(sign(PreambleRamReal),sign(PreambleRamImag));
DataShiftRam = zeros(1,L);
DataShiftRamMSB = 0;
flag = 0;
Counter = 1; %the index of input sequence
CounterFind = 0; %the number of point lager than threshold
SumArray = [];
if N==1
    SyncOffest = 0;
    Ncp = 0;
else
    SyncOffest = 12;
end
CounterLast =0; %store the index of peak last time
while(~flag)
	DataShiftRamMSB = DataShiftRam(L);
	DataShiftRam = [FrameSyncOutput(Counter),DataShiftRam(1:L-1)];
	DataShiftRamReal = real(DataShiftRam);
	DataShiftRamImag = imag(DataShiftRam);
	DataShiftRamQuan = complex(sign(DataShiftRamReal),sign(DataShiftRamImag));
	Sum = abs(fliplr(PreambleRamQuan) * DataShiftRamQuan' );
	SumArray(Counter) = Sum;
	Counter = Counter + 1;
	if(Sum > ThresholdValue)
		if(Counter-CounterLast < 10)
			CounterFind = CounterFind;
			CounterLast = CounterLast;
		else
			CounterLast = Counter;
			CounterFind = CounterFind + 1;
		end
	end
	if(CounterFind == RepeatTime)
		SymbolSyncOutput = FrameSyncOutput(Counter-SyncOffest:Counter+(N+Ncp)*(FRAME_NUM+1)-1-SyncOffest);
		break;
	end
	if(Counter > Length)
		break;
		FrameSyncOutput = [];
		error('Cannot find the beginning of the frame')
	end
end
plot(SumArray/max(SumArray));