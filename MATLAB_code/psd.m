%本函数画出输入信号功率谱
%作者：PENG JUN
%修改时间：20130819    
%参考资料：

%%%%%%%%%%%%%%%%%%%%%%%%%%
function psd(in_signal,varargin)
%  psd(x)    画出信号的功率谱，默认使用hann窗长度为1024.
%  psd(x,fs)  fs为采样率
%  psd(x,fs,'r') ‘r’线条颜色
narginchk(1, 3);
if nargin<2
    fs=3.2e7;
    c='r';
elseif nargin<3
    fs=varargin{1};
    c='r';
else
    fs=varargin{1};
    c=varargin{2};
end
    
% window = hann(1024);
nfft=2^(nextpow2(length(in_signal))-2)/4;
win=window(@hann,nfft);
olp=nfft/2;
[xx ,f1] = pwelch(in_signal,win,olp,nfft,fs);
xx = 10*log10(fftshift(xx));                           %将得出的xx转换为以0为中心显示，并且取功率对数
%%%%%%%使所有的点都在0dB以下%%%%%%%%
max_xx = max(xx);
max_xx = 0 - max_xx;
xx = xx + max_xx;
%%%%%%%%%使功率谱关于0对称显示%%%%%%%%%%

f=f1-max(f1)/2;
if strcmp(c,'rand')
    plot(f,xx,'color',[rand,rand,rand])
else
   plot(f,xx,c);
end
% title('信号功率谱');
% axis([-max(f1)/2,max(f1)/2,min(xx),0])
xlabel('Normalized Frequency(HZ)');
ylabel('Normalized Power Spectral Density(dB)');

grid on;



