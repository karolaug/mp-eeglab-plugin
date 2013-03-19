% jednak nadal nie wiem na czym polega bug i sprawia wrażenie jakby
% częstość była ujemna! ???








function [time omega amplitude envelope reconstruction miOut sigmaOut]=findBestGabor(mmax,mi0,sigma0,omega,signal,tmptime1,NFFT,T_TIME,T_RECONSTR)
% global tmptime
% stała kiedy przestać minimalizować:
global Giteracja

if isempty(Giteracja)
    Giteracja=1;
else
    Giteracja=Giteracja+1;
end
% Giteracja
epsilon=1e-3;% gdy względna zmiana jest mniejsza - STOP
time=1:length(signal);
time=time-tmptime1;

opt=optimset('TolX',epsilon,'TolFun',epsilon);

%minEnv6(P,signal,time)
% scaledT=time+tmptime1;
% smean=mean(scaledT);
% sstd=std(scaledT);
% mi0=(mi0-smean)/sstd;
% sigma0=sigma0/sstd;
% scaledT=(scaledT-mi0)/sstd;

% ok skalowanie dobre!
% plot(scaledT,gauss(scaledT,0,sigma0))
% hold on
% plot(scaledT,gauss(time+tmptime1,mi0,sigma0*sstd),'.r')
% hold off
% pause

% scaledT
% NNN=4;
TypTest=zeros(1,4);
miOut=mi0;
sigmaOut=sigma0;
for typ=1%:length(TypTest)

    if typ==1
        P(1).p=fminsearch(@(x) minEnv6(x,signal.*oscillation(time,-omega),time+tmptime1,typ),[0.5/sigma0^2 0 mi0],opt);
        P(1).envelope=asym2Envelope(P(1).p,time+tmptime1);
        P(1).amplitude=sum(signal.*P(1).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
        TypTest(typ)=abs(P(1).amplitude);
        miOut=P(1).p(3);
        sigmaOut=sqrt(1/2/P(1).p(1));

    elseif typ==2
        P(2).p=fminsearch(@(x) minEnv6(x,signal.*oscillation(time,-omega),time+tmptime1,typ),[0.75/sigma0^4 0 mi0],opt);
        P(2).envelope=asym4Envelope(P(2).p,time+tmptime1);
        P(2).amplitude=sum(signal.*P(2).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
        TypTest(typ)=abs(P(2).amplitude);

    elseif typ==3
        P(3).p=fminsearch(@(x) minEnv6(x,signal.*oscillation(time,-omega),time+tmptime1,typ),[1/sigma0^32 mi0],opt);
        P(3).envelope=sym32Envelope(P(3).p,time+tmptime1);
        P(3).amplitude=sum(signal.*P(3).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
        TypTest(typ)=abs(P(3).amplitude);

    else
        P(4).p=fminsearch(@(x) minEnv6(x,signal.*oscillation(time,-omega),time+tmptime1,typ),[1/sigma0^16 0 mi0],opt);
        P(4).envelope=asym16Envelope(P(4).p,time+tmptime1);
        P(4).amplitude=sum(signal.*P(4).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
        TypTest(typ)=abs(P(4).amplitude);
    end

end

[mm Typ]=max(TypTest);

envelope=P(Typ).envelope;
amplitude=P(Typ).amplitude;
P=P(Typ).p;

reconstruction=amplitude*envelope.*(oscillation(time,omega));

om2=fminsearch(@(x) bestOmega(x,signal.*envelope,time),omega);
Zmi=sum(signal.*envelope.*oscillation(time,-om2));

if abs(amplitude)<abs(Zmi)
    
    omega=om2;%2*pi*czestosci(mi);
    amplitude=Zmi;%Z(mi);
    reconstruction=amplitude*envelope.*(oscillation(time,om2));
else
    
    return
end

mmax=abs(mmax);

while (abs(amplitude)-mmax)/mmax > epsilon
    
    mmax=abs(amplitude);
    
    P=fminsearch(@(x) minEnv6(x,signal.*oscillation(time,-omega),time+tmptime1,Typ),P,opt);

    if Typ==1
        envelope=asym2Envelope(P,time+tmptime1);
        miOut=P(3);
        sigmaOut=sqrt(1/2/P(1));
    elseif Typ==2
        envelope=asym4Envelope(P,time+tmptime1);
    elseif Typ==3
        envelope=sym32Envelope(P,time+tmptime1);
    else
        envelope=asym16Envelope(P,time+tmptime1);
    end
    amplitude=sum(signal.*envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
    reconstruction=amplitude*envelope.*(oscillation(time,omega));

    % teraz minimalizacja częstości
    om2=fminsearch(@(x) bestOmega(x,signal.*envelope,time),omega);
    
    Zmi=sum(signal.*envelope.*oscillation(time,-om2));
    if abs(amplitude)<abs(Zmi)
        omega=om2;
        amplitude=Zmi;
        
        reconstruction=amplitude*envelope.*(oscillation(time,om2));
        
    else
        
        return
    end
    
end

    time=0:(length(signal)-1);
return

% minEnv ma zastąpić minPoly!
% P - wielomian 7 współczynników dla 6 stopnia!
% time! musi tu być znormalizowany!!! - średnia przez sigma!
function err=minEnv6(P,signal,x,typ)

env=0;
if typ==1
    env=asym2Envelope(P,x);
elseif typ==2
    env=asym4Envelope(P,x);
elseif typ==3
    env=sym32Envelope(P,x);
else
   env= asym16Envelope(P,x);
end
% mgauss=exp(-polyval(P,time));
% mgauss=mgauss/norm(mgauss);

err=-abs(sum(signal.* env ));
return



function y=asym2Envelope(P,x)

c=P(1);
d=P(2);
mi=P(3);
y=exp((-c*( x-mi).^2 )  ./ (1+ d*( x-mi) .* (atan(1e16*(x-mi))+pi/2)/pi));
y=y/norm(y);
return

function y=asym4Envelope(P,x)

c=P(1);
d=P(2);
mi=P(3);
y=exp((-c*( x-mi).^4 )  ./ (1+ d*( x-mi) .* (atan(1e16*(x-mi))+pi/2)/pi));
y=y/norm(y);
return

function y=asym16Envelope(P,x)

c=P(1);
d=P(2);
mi=P(3);
y=exp((-c*( x-mi).^16 )  ./ (1+ (( x-mi).^2).^d .* (atan(1e16*(x-mi))+pi/2)/pi));
y=y/norm(y);
return

function y=sym32Envelope(P,x)

c=P(1);
mi1=P(2);
y=exp((-c*(( x-mi1).^32) )) ;
y=y/norm(y);
return







function mg=MGauss(P,time)
mg=exp(-polyval(P,time));
mg=mg/norm(mg);


% czyli generalnie ok ew. inna relacja niz 1/x
% błąd był że czasem częstość może być ujemna!!! z mp6 ??

function err=minEnv(X,signal,time)
global Giteracja
mi=X(1);
sigma=X(2);

err=-abs(sum(signal.*gauss(time,mi,sigma)));
return











function y=gauss(time,mi,sigma)

y=exp(-((time-mi)/sigma).^2 / 2);
y=y/norm(y);
return


function err=bestOmega(om,signal,time)

tmp=exp(-i*om*time);
err=-abs(sum(signal.*tmp));
return

function z=oscillation(time,omega)

z=exp(i*omega*time);
return

