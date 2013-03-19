% robię jeszcze raz ze względu na przystosowaniedl długich sygnałów
% żeby nie brakowało pamęci ram i szybciej sie liczyło

%% PAMIETAC nei można za bardzo przedłużać bo energie/amplitudy nie będą
%% sie zgadzać!!!
%% żeby był gładki wykres trzeba końcówkę zaoknować!!!

% out_book(ii).envelope=env_part(mmaxInd).envelope;
% out_book(ii).oscilation=subMaxFreq(mmaxInd);
% out_book(ii).time=env_part(mmaxInd).time;
% out_book(ii).amplitude=mmax;
% TIME=(1:length(out_book(ii).envelope))-1;
% out_book(ii).reconstruction=mmax*env_part(mmaxInd).envelope.*exp(i*out_book(ii).oscilation*TIME);


function [time2, freqs2, W]=countAmap(book,time,SF)
% 'toten'
global TIME
% RESOLUTION=0;

%% wymiar obrazka
finalFlen=1e3;

% TIME=time;%globalny czas przydatny do obliczeń w innych miejscach

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
% to powinno być obliczane w zależności od długości atomu?
% B=[];
% if (finalFlen-1)/len1<0.5
%   [B,A]=butter(5,(finalFlen*0.9)/len1,'low');
% end

% tB=[];
% if (finalTlen-1)/len1<0.5
%   
%     'częstość filtru t:'
% %   [(finalFlen-1)/len1 finalFlen len1]
%     [tB,tA]=butter(round(5+30*finalTlen/(len1/2)),(finalTlen-1)/len1,'low');
% end
  
siglen=length(time);
% siglen
time2len=round(siglen*0.05)*4;
% time2len

winRL=hann(time2len)';
% size(winRL)
window2smooth=[winRL(1:end/2) ones(1,siglen-time2len) winRL(1+end/2:end)];
% [length(winRL(1:end/2)) length(ones(1,siglen-time2len)) length(winRL(1+end/2:end))]
% plot(window2smooth)
% pause
% figure
for ii=1:size(book,2)
    
    [ii size(book,2)]
%    book(ii)
    tmp_atom=real(book(ii).reconstruction);
    tmp_env=book(ii).envelope.*abs(book(ii).amplitude);
%     subplot 221
%     plot(book(ii).time,tmp_atom)
%     hold on
%     plot(book(ii).time,tmp_env,'r')
%     hold off
%     
%     pause
    
    
    
    
    
    
    
    
    %% tu zmienić od następych obliczen - już całe atomy obliczane!
%     atom=zeros(size(time));
%     size(book(ii).time)
    
% size(book(ii).time)
%     size(tmp_atom)
%     plot(tmp_atom)
%     [book(ii).time(1) book(ii).time(end)]
%     pause
%     atom(book(ii).time)=tmp_atom;
% size(book(ii).time)
atom=tmp_atom;

%     env=zeros(size(time));
%     env(book(ii).time)=tmp_env;
env=tmp_env;
    
    realY=atom;
% size(realY)
% size(window2smooth)
realYwin=realY.*window2smooth;
% pause
    zz=fft(realYwin);
    
    z=abs(zz(1:floor(length(zz)/2+1) ))';


z=resample(z,finalFlen*10,length(z));
    z=z/max(z);
% teraz ręczne przepróbkowanie:
[mm, mi]=max(z);
left=[mi:-10:1];
all=[left(end:-1:1) mi+10:10:length(z)];
all=all(1:finalFlen);
z=z(all);

envelope=resample(env,10*finalTlen,length(env));
envelope=envelope(1:10:end);

% z=abs(bookLT(5,ii))*z;%/max(z);
% size(z')
% size(envelope)
Wtmp=z*envelope;

% plot(freqs2,z)
% pause
% plot(time2,envelope)
% pause
% 
% surf(time2,freqs2',Wtmp);
% title(abs(book(ii).amplitude))
% colormap(jet)
% view(2)
% ylim([0 8000])
% shading interp
% pause
W = W + (Wtmp);
 
end
% time=time/SF;

% W=sqrt(abs(W));
