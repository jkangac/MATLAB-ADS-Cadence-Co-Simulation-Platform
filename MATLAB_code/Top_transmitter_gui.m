function [BitSequenOri, Pilotmod, TimeArrayInterp, DigitalOutputRoll, SymbolsOnSpecificCarrier, PAPR_VALUE, SamplingPoints,RFbandwidthGHz, Datarate] = Top_transmitter_gui (N, M, Ncp, FRAME_NUM, rolloff, f_s, S)

% default number in the function
PILOT_M = 2; %modulation order of pilot sequence
%S = 4; %up-sampling rate in raised cosine FIR filter 
span = 12; % span point of raised cosine FIR filter 

% TXSymbolsOnSpecificCarrier = [];
SpecificSubcarrierIndex=1;
%% Global variable
Pilotmod = []; % this is pilot sequence after modulation but before IFFT transformation
DigitalOutput = []; % this is digital output after digital processing
BitSequenOri = []; % this is the bit sequence of effective information
% Output signal generation
[DigitalOutput,~,BitSequenOri,Pilotmod, SymbolsOnSpecificCarrier] = Modulator(N, Ncp, M, FRAME_NUM, PILOT_M,SpecificSubcarrierIndex); % Modulation Scheme of pilot sequence, using QAM-4

% PAPR value calculation
[PAPR_VALUE] = PAPR_cal(DigitalOutput);

% shape filter generation
filter_h = rcosdesign(rolloff, span, S);
DigitalOutputRoll = upfirdn(DigitalOutput,filter_h,S);

% Simulated noise adding
% DigitalOutputRoll = awgn(DigitalOutputRoll,10,'measured');

ZeroNum = 1000;
ZeroAarry = zeros(1,ZeroNum);

%f_s = 2e8;

t_s = 1/f_s;
TimeArray = 0:t_s:(length(DigitalOutput)-1)*t_s;
TimeArrayInterp = 0:(t_s/S):(length(DigitalOutputRoll)-1+ZeroNum)*(t_s/S);
SamplingPoints = size(TimeArrayInterp,2);
% DigitalOutputRoll = interp1(TimeArray',DigitalOutput,TimeArrayInterp,'nearest');
DigitalOutputRoll = [DigitalOutputRoll,ZeroAarry];
TIME_AND_VAR_real = [TimeArrayInterp.', real(DigitalOutputRoll).'];
fid_w_1 = fopen('..\Matlab_ADS_Data\baseband_output_real.tim','w');
fprintf(fid_w_1,'%s\n','BEGIN TIMEDATA');
fprintf(fid_w_1,'%s\n','% time voltage');
[row,col] = size(TIME_AND_VAR_real);
for i = 1:row
	for j = 1:col
		if(j == col)
			fprintf(fid_w_1,'%e\n',TIME_AND_VAR_real(i,j));
		else
			fprintf(fid_w_1,'%e\t',TIME_AND_VAR_real(i,j));
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
			fprintf(fid_w_2,'%e\n',TIME_AND_VAR_imag(i,j));
		else
			fprintf(fid_w_2,'%e\t',TIME_AND_VAR_imag(i,j));
		end
	end
end
fprintf(fid_w_2,'%s','END');
fclose(fid_w_2);
%%  Save Oversampling and ChipRate for ADS       By Weimin
Datarate = M*f_s*N/(N+Ncp);
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
