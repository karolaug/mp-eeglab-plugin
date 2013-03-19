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


%% 17 maj poprawiam rysowanie mapki
% ponieważ mam funkcje prostokątne są też prążki od FFT...
% dlatego zrobię zszywaną funkcje obwiedni FFT
% którawygląda jak sin(x)/x tylko do pi/2 a dalej jest to 1/x








function [time2, freqs2, W]=countAmapNEW(book,time,SF)
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
   
    tmp_atom=real(book(ii).reconstruction);
    tmp_env=book(ii).envelope;
    
    
    
    
    
    
    
    
    
    
    
    %% tu zmienić od następych obliczen - już całe atomy obliczane!
    atom=zeros(size(time));
    size(book(ii).time)
    
    size(tmp_atom)
%     atom(book(ii).time)=tmp_atom;
atom=tmp_atom;

    env=zeros(size(time));
%     env(book(ii).time)=tmp_env;
env=tmp_env;
    
    realY=atom;
% size(realY)
% size(window2smooth)
% realYwin=realY.*window2smooth;

%     zz=fft(realYwin);

%% tu wcześnie trzeba wybrać optymalny fragment do obliczenia fft a nie po
%% prostu wyciąć pierwszą część...

% zz=fft(realY,(finalFlen)*2-1);

windowLen=min([length(realY) (finalFlen)*2-1])

% cutSignal(realY, (finalFlen)*2-1)
zz=fft(windowLen,(finalFlen)*2-1);
    
%     return
    z=abs(zz(1:floor(length(zz)/2+1) ))';
    
    zmax=max(z);
    zind=find(z>0.5*zmax);
%     zind
%     plot(abs(zz))
%     hold on
    xrewr=(1:length(z)) - zind(round(end/2));
%     if length(zind)>1
%         xrewr=xrewr-zind(round(end/2));
% %         round(end/2)
% %         zind
%     else
%         ii
%         subplot 311
%         plot(realY)
%         subplot 312
%         plot(abs(fft(realY)))
%         subplot 313
%         plot(abs(fft(realY,(finalFlen)*2-1)))
%        realY
%        pause
%     end
    %     zrewr=zmax*sin(xrewr/(length(xrewr)/2))/(xrewr/(length(xrewr)/2));
%     skalowanie=1.
%     1.114173272 wartość po której tylko 1/x
    zrewr=zmax*sin(xrewr*1.89/(length(zind)/2))./(xrewr*1.89/(length(zind)/2));

%     pause
    
    zrewr(find(isnan(zrewr)==1))=zmax;
    zrewr2=abs(zmax./(xrewr*1.89/(length(zind)/2)));
%         plot(zrewr,'r')
%     hold on
%     plot(zrewr2,'g')
%     pause
    szerokosc=mean([zind(round(end/2))-zind(1) zind(end)-zind(round(end/2))]);
    szerokosc=szerokosc*1.1141/(length(zind)/2);
    indpod=round(max([1 zind(round(end/2))-szerokosc]):min([zind(round(end/2))+szerokosc length(zrewr)]));
    zrewr2(indpod)=zrewr(indpod);
    z=zrewr2;
%     plot(z,'.b')
%     hold on
%     plot(zrewr(indpod),'.g')
%     hold off
%     pause
%     
%     plot(realY(cutSignal(realY, (finalFlen)*2-1)))
%     pause
%     plot(abs(zz))
%     
%     
%     pause
%     hold on
%     plot(zrewr2,'r')
%     pause
    
    
% plot(zrewr2)
% title(ii)
% % % z=resample(z,finalFlen*10,length(z));
% z=resample(zrewr2,finalFlen,length(zrewr2));
% pause
% plot(z)
% title('z')
% pause
% % teraz ręczne przepróbkowanie:
% [mm, mi]=max(z);
% left=[mi:-10:1];
% all=[left(end:-1:1) mi+10:10:length(z)];
% all=all(1:finalFlen);
% z=z(all);

envelope=resample(env,10*finalTlen,length(env));
envelope=envelope(1:10:end);

% z=abs(bookLT(5,ii))*z;%/max(z);
% size(z')
% size(envelope)
size(z)
size(W)
Wtmp=z'*envelope;

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

% wycina fragment o maksymalnej mocy aby na tym najlepszym policzyć widmo
function sind=cutSignal(signal, windowLen)


% size(signal)
% windowLen

vec10=zeros(size(signal));
vec10(1:windowLen)=ones(1,windowLen);
% plot(vec10)

% pause
c=xcorr(abs(hilbert(signal)),vec10);
% subplot 211
% plot(c)
% hold on
% plot(abs(hilbert(signal)),'r')

% title([length(signal) windowLen])
% subplot 212
[mm mi]=max(c);
s1=mi-length(vec10)+1;
s2=mi-length(vec10)+windowLen;
% pause
sind=s1:s2;

% 
% 
% mi
% hold on
% plot(abs(hilbert(signal)))
% plot(mi-length(vec10):mi-length(vec10)+windowLen,signal(mi-length(vec10):mi-length(vec10)+windowLen),'.r')
% 
