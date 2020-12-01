function[LongTrainingSeqOutput,SeqAfterIFFT,SeqOneOFDMSymTimeDom] = PreambleGen(N,Ncp,RepeatTime)

if N  < 128
	N=128;
end

if (mod(log2(N),1) ~= 0)
	error('N is invalid');
end

% S_N sequence generation
for i = 1:log2(N)
	intial_seq = [1,1];
	if i == 1
		SeqOneOFDMSymTimeDom = intial_seq;
	else
		SeqOneOFDMSymTimeDom = [SeqOneOFDMSymTimeDom,SeqOneOFDMSymTimeDom(1:2^(i-1)/2),-1.*SeqOneOFDMSymTimeDom(2^(i-1)/2+1:end)];
	end
end

if N ==1
	LongTrainingSeqOutput = repmat(SeqOneOFDMSymTimeDom,1,RepeatTime);
else
	% IFFT calculation
	SeqAfterIFFT = ifft(SeqOneOFDMSymTimeDom,N,2);
	% Repeat
	SeqAfterIFFTRepeat = repmat(SeqAfterIFFT,1,RepeatTime);
	% Adding CP
	LongTrainingSeqOutput = [SeqAfterIFFT(N-Ncp+1:end),SeqAfterIFFTRepeat];
end

