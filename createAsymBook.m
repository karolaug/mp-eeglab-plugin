% param=[minS maxS minP maxP dE]
% - dE - różnica 1- energia przy skoku parametru sigma lub pozycji

function [book,potSize]=createAsymBook(param,time)
%% ważne - atom może być dłuższy od sygnału - aby przesuwając się był
%% zawsze ciągły!

global ELONG
ELONG=3;
t=1:(length(time)*ELONG);
minS=param(1);
maxS=param(2);
% minP=param(3);
% maxP=param(4);
dE=param(5);

% najpierw znaleźć skok sigmy dla danej dokładności...
sig_start=(minS+maxS)/2;
gc=LTenvelope(sig_start,4,t);%gaborEnvelope(sig_start,t);
sig_stop=fminsearch(@(x) minSigEnerg(x,gc,dE,t),sig_start);

par_sig=sig_stop/sig_start;
if par_sig<1
    par_sig=1/par_sig;
end


csigma=minS;
iter=1;
book=[];

minFract=0;
maxFract=4;
% testowy atom
[tmp_env,p,k,sr]=LTenvelope((sig_stop+sig_start)/2,0,t);
FRACTii=minFract;
iter=1;
ff(iter)=FRACTii;
iter=iter+1;
while FRACTii<maxFract-1

   FRACTii=fminbnd(@(x) minFractEnerg(x,ff(iter-1),(sig_stop+sig_start)/2,dE,t),ff(iter-1),maxFract);
   ff(iter)=FRACTii;
   iter=iter+1;
end
% ff

% pause
% teraz znalezienie kolejnego Fract, który będzie < 4 oraz da skok energii
% większy o dE

% hold on
iter=1;
while csigma<maxS
    
%     iter
%     csigma
%     pause
    % tu dla danej sigmy trzeba znaleźć jaka zmiana pochylenia optymalna
    
    for ii=ff
        [tmp_env,p,k,sr]=LTenvelope(csigma,ii,t);%gaborEnvelope(csigma,t);
%         plot(tmp_env(p:k))
%         hold on
%         plot(sr-p,max(tmp_env),'ro')
%         hold off
%         pause
        book(iter).atom=tmp_env(p:k);
        %     book(iter).atom=book(iter).atom;%/norm(book(iter).atom);
        book(iter).skok=minPosEnerg(book(iter).atom,dE);
        % zabezpieczenie przed skokiem<1
        book(iter).skok=max([1 book(iter).skok]);
        book(iter).sigma=csigma;
        book(iter).sr=round(sr-p+1);
%         iter
%                 book(iter).skok
        iter=iter+1;

%         pause
    end
%     minPosEnerg(gc,dE);
    csigma=csigma*par_sig;
end

% potSize=0;
suma=0;
% szacowani wielkści słownika bez częstości
for ii=1:length(book)

%     [book(ii).sigma (length(time)/book(ii).skok-1) ]
% ii 
% length(time)
% book(ii).skok
    suma=suma+(length(time)/book(ii).skok-1);
end
potSize=suma;


function err=minSigEnerg(sig_x,gc,dE,t)

gx=LTenvelope(sig_x,4,t);%gaborEnvelope(sig_x,t);
err=abs(1-dE-dot(gx,gc));
% pause

return


function skok=minPosEnerg(gc,dE)

xc=abs(1-dE-xcorr(gc,gc));
[mmin,mind]=min(xc);
mind=mind(1);
skok=abs(length(gc)-mind);
return


function err=minFractEnerg(fx,fp,sig,dE,t)

envP=LTenvelope(sig,fp,t);
envX=LTenvelope(sig,fx,t);
err=abs(1-dE-dot(envX,envP));

return


function [env,p,k,sr]=LTenvelope(sig,fract,t)
global ELONG

mi=t(end)/ELONG;
x=(mi-t)/sig;
sigma=sig;%2^(gaborpar(1)/2/pi);
% fract=envpar(3);

alfa0=0.5/sigma^2;%1/2/sigma^2;
mi2=mi+sigma*fract;

alfa1=(mi2-mi)*alfa0*2;
t1=(mi2+mi)/2;

%t=(0:len-1)/sampfreq;
ind=find(t>mi2);

if isempty(ind)
    
    ind2=1:length(t);
else
    last=ind(1)-1;
    if last>0
        ind2=1:last;
    else
        ind2=[]; 
    end
end
    
% pi wprowadzone żeby sie lepiej zgadzało... z Artura gaborT
%alfa0=pi/sigma^2;%1/2/sigma^2;

g1=exp(-alfa0*(t(ind2)-mi ).^2);

e1=exp(-alfa1*(t(ind)-t1));

y=[g1 e1];% dla historycznego porządku: .*exp(i*freq*TIME); dlatego trzeba będzie potem zmienić żeby odtwarzać bo fft ma minus
ind=find(y>eps);
p=min(ind);
k=max(ind);
% y=y(p:k);
[mmsr,sr]=max(y);
ny=norm(y);
env=y/ny;


% t - musi być 3 razy dłuższe niż sam sygnał
% p,k - granice użyteczności atomu
% wg Rafała dalej niż 4 sigma bąd numeryczny jest wiekszy
% function [env,p,k,sr]=gaborEnvelope(sig,t)
%  
% % global ELONG
% eps=1e-4;
% % t=1:(length(time)*ELONG);
% mi=t(end)/2;
% x=(mi-t)/sig;
% y=exp(-x.^2 /2);
% ind=find(y>eps);
% p=min(ind);
% k=max(ind);
% 
% sr=(p+k)/2-p+1;
% 
% 
% env=y/norm(y);
% return
