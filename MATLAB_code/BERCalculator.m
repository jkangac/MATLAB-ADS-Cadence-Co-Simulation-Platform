function [BIT_ERROR_NUM, BIT_ERROR_RATE, SYM_ERROR_NUM, SYM_ERROR_RATE] = BERCalculator(BitSequenOri, BitSequenReceived, FRAME_NUM)
%% this model is used to calculate the symbol error rate and bit error rate

%% Variable list:
% BIT_ERROR_NUM: the total number of error bit
% BIT_ERROR_RATE: the bit error rate
% SYM_ERROR_NUM: the total number of  error OFDM symbol
% SYM_ERROR_RATE: the OFDM symbol error rate


%% OFDM symbol error number and symbol error rate calculation
SYM_ERROR_NUM_TEMP = 0;
for nFrame = 1:FRAME_NUM
	BitSequenOriOneFrame = BitSequenOri(1,(nFrame-1)*(length(BitSequenOri)/FRAME_NUM)+1:nFrame*(length(BitSequenOri)/FRAME_NUM));
	BitSequenReceivedOneFrame = BitSequenReceived(1,(nFrame-1)*(length(BitSequenReceived)/FRAME_NUM)+1:nFrame*(length(BitSequenReceived)/FRAME_NUM));
	[BIT_ERROR_NUM_PER_FRAME, BIT_ERROR_RATE_PER_FRAME] = biterr(BitSequenOriOneFrame, BitSequenReceivedOneFrame);
	if BIT_ERROR_NUM_PER_FRAME ~= 0
		SYM_ERROR_NUM_TEMP = SYM_ERROR_NUM_TEMP + 1;
	else
		SYM_ERROR_NUM_TEMP = SYM_ERROR_NUM_TEMP;
	end
end
SYM_ERROR_NUM = SYM_ERROR_NUM_TEMP;
SYM_ERROR_RATE = SYM_ERROR_NUM/FRAME_NUM;
[BIT_ERROR_NUM, BIT_ERROR_RATE] = biterr(BitSequenOri, BitSequenReceived);