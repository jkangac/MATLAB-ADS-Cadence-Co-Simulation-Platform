function [DataBitAllFrame,SymbolsOnSpecificCarrier] = Demodulator(ReceivedSignal, Pilotmod, N, Ncp, M, FRAME_NUM,SpecificSubcarrierIndex)
% This file is de-modulator model
% This model is used to demodulate the received signal to original bit sequence
% This model could also calculate the bit error rate and symbol error rate

%% Variable list:
% DataBitAllFrame: the received bit sequence 
% ReceivedSignal: the received signal from channel model
% N: point number of FFT and IFFT
% M: modulation scheme
% Ncp: point number of cylic 
%Pilot_Data: the pilot sequence after modulation, directly from modulator 

%% Initialization
% QAM-demapper
qamDemod = comm.RectangularQAMDemodulator(...
'BitOutput', true, ...
'NormalizationMethod', 'Average power');

%% First Part: Channel estimation employing LS
if N==1
    EstimationSequenReceived = ReceivedSignal(1,1);
    HLS = EstimationSequenReceived/Pilotmod;
else
    EstimationSequenReceived = ReceivedSignal(1,1:(N+Ncp));
    EstimationSequenWithoutCp = EstimationSequenReceived(1,Ncp+1:end);
    EstimationSequenFFT = (sqrt((N+Ncp)/(N-2)))*(ifftshift(fft(EstimationSequenWithoutCp)));
    for i=1:N
        X(i,i)=Pilotmod(i);
    end
    Y=EstimationSequenFFT(1,1:end).';
    H_LS = (inv(X))*Y;
    for i=1:N
        HLS(i,i)=H_LS(i);
    end
end
%% Second Part: Signal demodulation
if N==1
    DataSequenReceived = ReceivedSignal(1,2:end);
else
    DataSequenReceived = ReceivedSignal(1,(N+Ncp)+1:end);
end
DataSequenReceivedBeforeReshape = [];
DataBitAllFrame = [];
SymbolsOnSpecificCarrier = [];
for nFrame = 1:FRAME_NUM
    if N ==1
        DataModOneFrame = DataSequenReceived(1,(nFrame-1)+1:nFrame);
        DataModOneFrameAfterES = (inv(HLS)*(DataModOneFrame.')).';
        SymbolsOnSpecificCarrier(nFrame) = DataModOneFrameAfterES; 
        qamDemod.ModulationOrder = 2^M;
        DataDemod = step(qamDemod, DataModOneFrameAfterES);		
        release(qamDemod);
        DataBitOneFrame = reshape(DataDemod,1,M);
        DataSequenReceivedBeforeReshape(nFrame,:) = DataBitOneFrame;
    else
        DataSequenOneFrameWithCp = DataSequenReceived(1,(nFrame-1)*(N+Ncp)+1:nFrame*(N+Ncp));
        DataSequenOneFrameWithoutCp = DataSequenOneFrameWithCp(1, Ncp+1:end);
        DataSequenOneFrameFFT = (sqrt((N+Ncp)/(N-2)))*(ifftshift(fft(DataSequenOneFrameWithoutCp)));
        DataModOneFrame = DataSequenOneFrameFFT(1, 1:end);
        DataModOneFrameAfterES = (inv(HLS)*(DataModOneFrame.')).';
        SymbolsOnSpecificCarrier(nFrame) = DataModOneFrameAfterES(SpecificSubcarrierIndex); 
        DataDemod = []; % temporary store the one frame data after demodulation
        qamDemod.ModulationOrder = 2^M;
        for nSymbol = 1:N
            DataDemod = [DataDemod , step(qamDemod, DataModOneFrameAfterES(1, nSymbol))];		
            release(qamDemod);
        end
        DataBitOneFrame = reshape(DataDemod,1,M*N);
        DataSequenReceivedBeforeReshape(nFrame,:) = DataBitOneFrame;
    end
end
DataBitAllFrame = reshape(DataSequenReceivedBeforeReshape, 1, FRAME_NUM*(N*M));
%scatterplot(SymbolsOnSpecificCarrier);
