%% this version combine modulator, demodulator, channel model and ber calculator together
clear all;
clc;
close all; %close all the figure or other windows to make the result clear

%% Parameter list:
N = 64; % Number of IFFT and FFT number
M = 6; % Modulation scheme is 16-QAM
Ncp = 16; % length of cyclic prefix
FRAME_NUM = 240; % the number of OFDM symbol
PILOT_M = 2; % 
SpecificSubcarrierIndex = 1;
TXSymbolsOnSpecificCarrier = [];

%% Global variable
Pilotmod = []; % this is pilot sequence after modulation but before IFFT transformation
DigitalOutput = []; % this is digital output after digital processing
BitSequenOri = []; % this is the bit sequence of effective information
DataBitAllFrame = []; % Received bit sequence

[DigitalOutput,~,BitSequenOri,Pilotmod, TXSymbolsOnSpecificCarrier] = Modulator(N, Ncp, M, FRAME_NUM, PILOT_M,SpecificSubcarrierIndex); % Modulation Scheme of pilot sequence, using QAM-4
[PAPR_VALUE] = PAPR_cal(DigitalOutput);
%% Add match filter
S = 4; % point per symbol, up-sampling rate
%F = 200; %RCC filter order
rolloff = 0.25;
span = 12;
% filtorder = S*F; % Filter order
% delay = filtorder/(S*2); % Group delay (# of input samples)
% rrcfilter = rcosine(1,S,'fir/sqrt',rolloff,delay)*sqrt(S);
filter_h = rcosdesign(rolloff, span, S);
fvtool(filter_h, 'impulse')
DigitalOutputRoll = upfirdn(DigitalOutput,filter_h,S);
% DigitalOutputRoll=rcosflt(DigitalOutput,1,S,'filter',rrcfilter);
% DigitalOutputRoll=DigitalOutputRoll(delay*S+1:end-delay*S);
%% TIME generation
ZeroNum = 1000;
ZeroAarry = zeros(1,ZeroNum);
f_s = 2e7;
t_s = 1/f_s;
TimeArray = 0:t_s:(length(DigitalOutput)-1)*t_s;
TimeArrayInterp = 0:(t_s/S):(length(DigitalOutputRoll)-1+ZeroNum)*(t_s/S);
SamplingPoints = size(TimeArrayInterp,2);
% DigitalOutputRoll = interp1(TimeArray',DigitalOutput,TimeArrayInterp,'nearest');
DigitalOutputRoll = [DigitalOutputRoll,ZeroAarry];

%% save .dat file
% save DigitalOutputRoll_64QAM


TIME_AND_VAR_real = [TimeArrayInterp.', real(DigitalOutputRoll).'];
fid_w_1 = fopen('..\Matlab_ADS_Data\baseband_output_real.tim','w');
fprintf(fid_w_1,'%s\n','BEGIN TIMEDATA');
fprintf(fid_w_1,'%s\n','% time voltage');
[row,col] = size(TIME_AND_VAR_real);
for i = 1:row
	for j = 1:col
		if(j == col)
			fprintf(fid_w_1,'%g\n',TIME_AND_VAR_real(i,j));
		else
			fprintf(fid_w_1,'%g\t',TIME_AND_VAR_real(i,j));
		end
	end
end
fprintf(fid_w_1,'%s','END');
fclose(fid_w_1);
TIME_AND_VAR_imag = [TimeArrayInterp.', imag(DigitalOutputRoll).'];
fid_w_2 = fopen('..\Matlab_ADS_Data\baseband_output_imag.tim','w');
fprintf(fid_w_2,'%s\n','BEGIN TIMEDATA');
fprintf(fid_w_2,'%s\n','% time voltage');
[row,col] = size(TIME_AND_VAR_imag);
for i = 1:row
	for j = 1:col
		if(j == col)
			fprintf(fid_w_2,'%g\n',TIME_AND_VAR_imag(i,j));
		else
			fprintf(fid_w_2,'%g\t',TIME_AND_VAR_imag(i,j));
		end
	end
end
fprintf(fid_w_2,'%s','END');
fclose(fid_w_2);


%save baseband_output_real.tim -ascii TIME_AND_VAR_real;
%save baseband_output_imag.tim -ascii TIME_AND_VAR_imag;

%VAR_real = real(DigitalOutputRoll);
%VAR_imag = imag(DigitalOutputRoll);
%save baseband_output_real.txt -ascii VAR_real;
%save baseband_output_imag.txt -ascii VAR_imag;

% %%  Save Oversampling and ChipRate for ADS       By Weimin
RFbandwidthGHz = f_s/10^9;
delete('..\Matlab_ADS_Data\ChipRate.txt');
OverSampling = S;
ChipRate = f_s;
Num = SamplingPoints;
ADSVAR=[1 OverSampling ChipRate Num];
fp=fopen('..\Matlab_ADS_Data\ChipRate.txt', 'a');
fprintf(fp,'%s\n','BEGIN ADSVAR');
fprintf(fp,'%s\n','% index(real) OverSampling(real) ChipRate(real) Num(real)');
fprintf(fp,'%g\t',ADSVAR);
fprintf(fp,'\n');
fprintf(fp,'%s','END');
fclose(fp);


%% Received Part
% read the data from file
fid_1=fopen('..\Matlab_ADS_Data\ADS_OUTPUT_Q.tim','r');
%fid_1=fopen('baseband_output_imag.tim','r'); 
TIME_AND_VAR_imag_rece =[]; 
while 1     
	tline=fgetl(fid_1);     
	if ~ischar(tline),break;
	end     
	tline=str2num(tline);     
	TIME_AND_VAR_imag_rece = [TIME_AND_VAR_imag_rece;tline];
end

fid_2=fopen('..\Matlab_ADS_Data\ADS_OUTPUT_I.tim','r'); 
%fid_2=fopen('baseband_output_real.tim','r'); 
TIME_AND_VAR_real_rece =[]; 
while 1     
	tline=fgetl(fid_2);     
	if ~ischar(tline),break;
	end     
	tline=str2num(tline);     
	TIME_AND_VAR_real_rece = [TIME_AND_VAR_real_rece;tline];
end
% RXSymbolsOnSpecificCarrier = [];
DigitalReceived = complex(TIME_AND_VAR_real_rece(1:end,2),TIME_AND_VAR_imag_rece(1:end,2)).';

%% test
% DigitalReceived = p31.';

%% ideal case
% DigitalReceived = DigitalOutputRoll;

%Add some delay in the signal sequence
% DelayMax = 20;
% DelayMin = 20;
% DelayPointFront = randi([DelayMin,DelayMax]);
% DelayPointBack = randi([DelayMin,DelayMax]);
% DelaySeqFront = zeros(1,DelayPointFront);
% DelaySeqBack = zeros(1,DelayPointBack);
% DigitalReceived = [DelaySeqFront,DigitalReceived,DelaySeqBack];
DigitalInputRoll = upfirdn(DigitalReceived,filter_h,1,S);
% DigitalInputRoll = DigitalInputRoll(span+1:end-span);
[Counter,SymbolSyncOutput] = SymbolSync(DigitalInputRoll,N,Ncp,FRAME_NUM,10);
[DataBitAllFrame,RXSymbolsOnSpecificCarrier] = Demodulator(SymbolSyncOutput, Pilotmod, N, Ncp, M, FRAME_NUM,SpecificSubcarrierIndex);
[BIT_ERROR_NUM, BIT_ERROR_RATE, SYM_ERROR_NUM, SYM_ERROR_RATE] = BERCalculator(BitSequenOri, DataBitAllFrame, FRAME_NUM);
disp(BIT_ERROR_RATE);
% EVM Calculation
[rmsEVM,maxEVM,pctEVM,numSym] =  Evm_Calculation (TXSymbolsOnSpecificCarrier.', RXSymbolsOnSpecificCarrier.');
figure(1)
scatterplot(TXSymbolsOnSpecificCarrier);
figure(2)
scatterplot(RXSymbolsOnSpecificCarrier);