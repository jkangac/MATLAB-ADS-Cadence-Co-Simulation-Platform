function [DigitalReceived, BIT_ERROR_NUM, BIT_ERROR_RATE, SYM_ERROR_NUM, SYM_ERROR_RATE,SymbolsOnSpecificCarrier] = Top_receiver_gui (N, M, Ncp, FRAME_NUM, rolloff, f_s, S,Pilotmod,BitSequenOri,DigitalReceivedOri)

% default number in the function
span = 12; % span point of raised cosine FIR filter 
SpecificSubcarrierIndex = 1; %% Revised by Weimin

% read the data from file
fid=fopen('..\Matlab_ADS_Data\ADS_OUTPUT_Q.tim','r'); 
TIME_AND_VAR_imag_rece =[]; 
while 1     
	tline=fgetl(fid);     
	if ~ischar(tline),break;
	end     
	tline=str2num(tline);     
	TIME_AND_VAR_imag_rece = [TIME_AND_VAR_imag_rece;tline];
end

fid=fopen('..\Matlab_ADS_Data\ADS_OUTPUT_I.tim','r'); 
TIME_AND_VAR_real_rece =[]; 
while 1     
	tline=fgetl(fid);     
	if ~ischar(tline),break;
	end     
	tline=str2num(tline);     
	TIME_AND_VAR_real_rece = [TIME_AND_VAR_real_rece;tline];
end
DigitalReceived = complex(TIME_AND_VAR_real_rece(1:end,2),TIME_AND_VAR_imag_rece(1:end,2)).'; %because ADS will generate one more point in the beginning of sequence
%DigitalReceived = DigitalReceivedOri;%used for testing
% raise cosine filter design
filter_h = rcosdesign(rolloff, span, S);
DigitalInputRoll = upfirdn(DigitalReceived,filter_h,1,S);
%DigitalInputRoll = DigitalInputRoll(span+1:end-span);
[~,SymbolSyncOutput] = SymbolSync(DigitalInputRoll,N,Ncp,FRAME_NUM,10);



[DataBitAllFrame, SymbolsOnSpecificCarrier] = Demodulator(SymbolSyncOutput, Pilotmod, N, Ncp, M, FRAME_NUM,SpecificSubcarrierIndex);
[BIT_ERROR_NUM, BIT_ERROR_RATE, SYM_ERROR_NUM, SYM_ERROR_RATE] = BERCalculator(BitSequenOri, DataBitAllFrame, FRAME_NUM);