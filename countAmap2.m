function [time2, freqs2, W]=countAmap2(book,time,SF)
% compute t-f map
% book: book containing parameters of atoms to be plotted
% time: indexes of samples
% SF: sampling frequency
% Copyright Konrad Kwaskiewicz, 2012
%% wymiar obrazka
finalFlen=1e3;


len1=length(time);% długość czasu trwania sygnału
finalTlen=min([2e3 len1]);
freqs2=SF/2*linspace(0,1,finalFlen);% częstość w jednostkach rzeczywistych
time2=(time(end)-time(1))/SF*linspace(0,1,finalTlen);%czas w jednostkach rzeczywistych
% len2=length(freqs2);

% przeliczenie czasu rzeczywistego w przypadku gdy sygnał dłuższy
if len1>finalTlen
    time2=max(time)*linspace(0,1,finalTlen)/SF;
end

% obrazek do wyświetlenia
% W=zeros(len2,length(time2));
W=zeros(finalFlen,finalTlen);

siglen=length(time);
% siglen
time2len=round(siglen*0.05)*4;
winRL=hann(time2len)';
window2smooth=[winRL(1:end/2) ones(1,siglen-time2len) winRL(1+end/2:end)];

for ii=1:size(book,2)
    atom=real(book(ii).reconstruction);
    env=book(ii).envelope.*abs(book(ii).amplitude);

    realYwin=atom.*window2smooth;
    zz=fft(realYwin);
    z=abs(zz(1:floor(length(zz)/2+1) ));
    z=halfWidthGauss(z);
    
    z=resample(z,finalFlen,length(z));
    z=z/max(z);
    envelope=resample(env,finalTlen,length(env));
    Wtmp=z'*envelope;
    W = W + (Wtmp);
    
end

function y=halfWidthGauss(z)

[mz mzi]=max(z);
id=find(z(1:mzi)-0.5*mz<0);
if isempty(id)
    L=mzi;%-id(end);
else
    L=mzi-id(end);
end
id=find(z(mzi:end)-0.5*mz<0);
R=id(1);
% [ R L]
sigma=(L+R)/2/sqrt(log(4));
t=1:length(z);
y=mz*exp(-(t-mzi).^2/2/sigma^2);
