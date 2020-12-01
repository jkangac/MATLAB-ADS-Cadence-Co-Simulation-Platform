function [DigitalOutputWithPreamble, DigitalOutputWithoutPreamble, DataSequence, Pilotmod, SymbolsOnSpecificCarrier] = Modulator(N, Ncp, M, FRAME_NUM, PILOT_M,SpecificSubcarrierIndex)
% Thia file is modulator model
% This model could generate the bit sequence and do the modulation

%% Variable list:
% DigitalOutput: the output data to digital to analog converter
% DataSequence: bit sequence of effect information
% Pilotmod: the pilot sequence after modulation
% N: point number of FFT and IFFT
% M: modulation scheme
% Ncp: point number of cylic 
% PILOT_M: Modulation scheme of pilot sequence, using QAN-4
POLY_LENGTH = 7;
POLY_TAP = 1;
%% Initialization
% QAM mapper
qamMapper = comm.RectangularQAMModulator(...
'BitInput', true, ...
'NormalizationMethod', 'Average power');

%% First Part:
[Preamble,~,~] = PreambleGen(N,Ncp,10);
%% First Part temp: pilot generator
BIT_NUM_PILOT_FRAME = N * PILOT_M;%Assume receiver side know the sequence
%PilotSequence = rand(1, BIT_NUM_PILOT_FRAME)<0.5;
[PilotSequence, ~] = prbs_gen(POLY_LENGTH, POLY_TAP, 1, BIT_NUM_PILOT_FRAME);
PilotSequenceParallel = reshape(PilotSequence, PILOT_M, N);
qamMapper.ModulationOrder = 2^PILOT_M;
Pilotmod = [];
for nSymbol = 1:N
  Pilotmod = [Pilotmod,step(qamMapper,PilotSequenceParallel(:,nSymbol))];
  release(qamMapper);
end
if N == 1
    PilotWithCp = Pilotmod;
else
    TotalPilot = Pilotmod;
    TotalPilotIFFT = (sqrt((N-2)/(N+Ncp)))*(ifft(ifftshift(TotalPilot)));
    PilotWithCp = [TotalPilotIFFT(N-Ncp+1:N),TotalPilotIFFT];
end

%% Second Part: bit sequence generator
BIT_NUM_FRAME = N*M;
[DataSequence, ~] = prbs_gen(POLY_LENGTH, POLY_TAP, 1, BIT_NUM_FRAME*FRAME_NUM);
%DataSequence = rand(1,BIT_NUM_FRAME*FRAME_NUM) < 0.5;
DataSequenceReshape = reshape(DataSequence,FRAME_NUM,BIT_NUM_FRAME);
SymbolsOnSpecificCarrier = [];
for nFrame = 1:FRAME_NUM
	OneFrameTemp = DataSequenceReshape(nFrame,:);
	% serial to parallel
	OneFrameTempParallel = reshape(OneFrameTemp,M,N);
	% Mapper
	qamMapper.ModulationOrder = 2^M;
	Datamod = [];
	for nSymbol = 1:N
        Datamod = [Datamod,step(qamMapper, OneFrameTempParallel(:,nSymbol))];
        release(qamMapper);
	end		
	% Get the symbol on specific subcarrier
    TotalData = Datamod;
	% IFFT, the energy is normalized
    if N == 1
        SymbolsOnSpecificCarrier(nFrame) = Datamod;
        AllFrameData(1, (nFrame-1)+1:nFrame) = Datamod;
    else
        SymbolsOnSpecificCarrier(nFrame) = Datamod(SpecificSubcarrierIndex);
        TotalDataIFFT = (sqrt((N-2)/(N+Ncp)))*(ifft(ifftshift(TotalData)));
        DataWithCp = [TotalDataIFFT(N-Ncp+1:N),TotalDataIFFT];
        AllFrameData(1, (nFrame-1)*(N+Ncp)+1:nFrame*(N+Ncp)) = DataWithCp;
    end
end

AllFrameDataWithPilot = [PilotWithCp,AllFrameData];

%% Third Part: Normalization
NORMALIZED_COE = max(abs(AllFrameDataWithPilot));
DigitalOutputWithoutPreamble = AllFrameDataWithPilot/NORMALIZED_COE;

% data with preamble generation
AllFrameDataWithPilot = [Preamble ,PilotWithCp,AllFrameData];
NORMALIZED_COE = max(abs(AllFrameDataWithPilot));
DigitalOutputWithPreamble = AllFrameDataWithPilot/NORMALIZED_COE;