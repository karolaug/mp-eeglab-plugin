function [book] = defineMixedInbook(param,time)
% prepare book of envelopes according to params
% Copyright Konrad Kwaskiewicz, 2012
t=1:(length(time)*3);
minS=param(1);
maxS=param(2);
dE=param(3);

% szacuj�co ile ma skaka� sigma dla tej samej pozycji, �eby r�nica energii
% by�a ustalona

sig_start=(minS+maxS)/2;
gc=gaborEnvelope(sig_start,t);
sig_stop=fminsearch(@(x) minSigEnerg(x,gc,dE,t),sig_start);

par_sig=sig_stop/sig_start;
if par_sig<1
    par_sig=1/par_sig;
end

csigma=minS;
iter=1;
book=[];
breakV=maxS*sqrt(par_sig);

%generate symmetric and asymmetric atom envelopes for all time scales
while csigma<breakV
    [tmp_env,p,k,sr]=gaborEnvelope(csigma,t);% obwiednia pocz�tek i koniec, �rodek
    book(iter).atom=tmp_env(p:k);
    book(iter).skok=minPosEnerg(book(iter).atom,dE);
    book(iter).skok=max([1 book(iter).skok]);%window shift
    book(iter).sigma=csigma;
    book(iter).sr=round(sr);
    book(iter).type=1;% 1 - gabor atom
    book(iter).decay=0;
    iter=iter+1;

    [y,p,k,sr]=gabor2asymEps(0.5/csigma^2,sr,1.5/csigma,t);
    book(iter).atom=y(p:k);
    book(iter).skok=book(iter-1).skok;% dla asym bierzemy jak dla gabora
    book(iter).sigma=csigma;
    book(iter).decay=1.5/csigma;
    book(iter).sr=round(sr);
    book(iter).type=2;% 2 - asymetric atom
    
    csigma=csigma*par_sig;
    iter=iter+1;
end

%% now prepare envelopes for rectangular atoms 
sig_start2=(minS+maxS)/2;
gc=gabor8Envelope(sig_start2,t);
sig_stop2=fminsearch(@(x) minSigEnerg8(x,gc,dE,t),sig_start2);
par_sig=sig_stop2/sig_start2;
if par_sig<1
    par_sig=1/par_sig;
end
csigma=minS;

breakV=maxS*sqrt(par_sig); % stopping criterion
while csigma<breakV
    [tmp_env,p,k,sr]=gabor8Envelope(csigma,t);% obwiednia pocz�tek i koniec, �rodek
    book(iter).atom=tmp_env(p:k);
    book(iter).skok=minPosEnerg8(book(iter).atom,dE);
    book(iter).skok=max([1 book(iter).skok]);
    book(iter).sigma=csigma;
    book(iter).sr=round(sr);
    book(iter).type=3;% 8 - gabor z pot?g?
    book(iter).decay=0;
    csigma=csigma*par_sig;    
    iter=iter+1;
end






function [env,p,k,sr]=gaborEnvelope(sig,t)
 
eps=1e-4;
mi=t(end)/2;
x=(mi-t)/sig;
y=exp(-x.^2 /2);
ind=find(y>eps);
p=min(ind);
k=max(ind);
sr=(p+k)/2-p+1;
env=y/norm(y);
return


function err=minSigEnerg(sig_x,gc,dE,t)

gx=gaborEnvelope(sig_x,t);
err=abs(1-dE-dot(gx,gc));
return


function skok=minPosEnerg(gc,dE)

xc=abs(1-dE-xcorr(gc,gc));
[~,mind]=min(xc);
mind=mind(1);
skok=abs(length(gc)-mind);
return


function [y,p,k,sr]=gabor2asymEps(alfa,mi,dec,x)

eps=1e-4;
tmp_x_mi=x-mi;
y=exp((-alfa*( tmp_x_mi ).^2 )./ (1+ dec*( tmp_x_mi ) .* (atan(1e16*(tmp_x_mi))+pi/2)/pi));
ind=find(y>eps);
p=min(ind);
k=max(ind);
sr=mi+1-p;
y=y/norm(y);
return

function [env,p,k,sr]=gabor8Envelope(sig,t)

eps=1e-4;
mi=t(end)/2;
x=(mi-t)/sig;
y=exp(-7*x.^8 /8);% 8 !
ind=find(y>eps);
p=min(ind);
k=max(ind);
sr=(p+k)/2-p+1;
env=y/norm(y);
return

function err=minSigEnerg8(sig_x,gc,dE,t)

gx=gabor8Envelope(sig_x,t);
err=abs(1-dE-dot(gx,gc));
return


function skok=minPosEnerg8(gc,dE)

xc=abs(1-dE-xcorr(gc,gc));
[~,mind]=min(xc);
mind=mind(1);
skok=abs(length(gc)-mind);
return
