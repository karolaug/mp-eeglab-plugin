

% param=[minS maxS minP maxP dE]
% - dE - różnica 1- energia przy skoku parametru sigma lub pozycji

function [book,potSize]=createGaborBook(param,time)
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
gc=gaborEnvelope(sig_start,t);
sig_stop=fminsearch(@(x) minSigEnerg(x,gc,dE,t),sig_start);
% sig_stop
% sig_start
% pause
par_sig=sig_stop/sig_start;
if par_sig<1
    par_sig=1/par_sig;
end
% dot(gaborEnvelope(sig_start*par_sig,t),gc)
% plot(gc)
% hold on
% plot(gaborEnvelope(sig_start*par_sig,t))

% par_sig
% pause

csigma=minS;
iter=1;
book=[];
% hold on
while csigma<maxS
    
%     iter
%     csigma
%     pause
    [tmp_env,p,k,sr]=gaborEnvelope(csigma,t);
    book(iter).atom=tmp_env(p:k);
%     book(iter).atom=book(iter).atom;%/norm(book(iter).atom);
    book(iter).skok=minPosEnerg(book(iter).atom,dE);
    % zabezpieczenie przed skokiem<1
    book(iter).skok=max([1 book(iter).skok]);
    book(iter).sigma=csigma;
    book(iter).sr=round(sr);
%     book(iter).skok
%     plot(book(iter).atom)
%     plot(sr,max(book(iter).atom),'*r')
%     pause
    minPosEnerg(gc,dE);
    csigma=csigma*par_sig;
    iter=iter+1;
    
end
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
% t - musi być 3 razy dłuższe niż sam sygnał
% p,k - granice użyteczności atomu
% wg Rafała dalej niż 4 sigma bąd numeryczny jest wiekszy
function [env,p,k,sr]=gaborEnvelope(sig,t)
 
% global ELONG
eps=1e-4;
% t=1:(length(time)*3);
mi=t(end)/2;
x=(mi-t)/sig;
y=exp(-x.^2 /2);
ind=find(y>eps);
p=min(ind);
k=max(ind);

%% jednak bez tego!
% % zamiast pozątka 9 końca konwencjonalnego lepiej policzyć xcorr z
% % jedynkami!
% zz=zeros(1,length(t));
% zz(1:end/ELONG)=ones(1,length(t)/ELONG);
% xc=xcorr(y,zz);
% [mmax,mind]=max(xc);
% p2=mind+1-length(t);
% k2=p2+length(t)/ELONG-1;
% sig
% [k-p k2-p2 length(t)/ELONG]
sr=(p+k)/2-p+1;
% sr
% if k-p>length(t)/ELONG
%     sr=(p2+k2)/2;
%     'jest'
% end
% sr
% if k2-p2>length(t)/ELONG
%     sr=(p2+k2)/2;
%     'sr1'
%     [sr p2 k2]
%     
% else
%     'sr2'
%     sr=(p+k)/2;
%     [sr p k]
% end

% pause
% % mind
% mind=mind(1);
% % clf
% % plot(xc)
% % hold on
% % plot(y)
% % plot([zeros(1,mind-length(t)) ones(1,length(t)/ELONG) zeros(1,10)])

% 
% p=max([p p2]);
% k=min([k k2]);

env=y/norm(y);
return


function err=minSigEnerg(sig_x,gc,dE,t)

gx=gaborEnvelope(sig_x,t);
err=abs(1-dE-dot(gx,gc));
% pause

return


function skok=minPosEnerg(gc,dE)

xc=abs(1-dE-xcorr(gc,gc));
[mmin,mind]=min(xc);
mind=mind(1);
skok=abs(length(gc)-mind);
return
