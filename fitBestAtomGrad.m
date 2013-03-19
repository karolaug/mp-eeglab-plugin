function [omega amplitude envelope reconstruction miOut sigmaOut decayOut] = fitBestAtomGrad( mmax,mi0,sigma0,omega,decay0,signal,tmptime1,TYPE)


epsilon=1e-3;% gdy względna zmiana jest mniejsza - STOP
time=1:length(signal);
time=time-tmptime1;

opt=optimset('TolX',epsilon,'TolFun',epsilon);

miOut=mi0;
sigmaOut=sigma0;
decayOut=decay0;

% je�li typ 1 - minim  tylko Gabora z lekk� asymetri�
% je�li 2 - to samo co 1 tylko inne parametry startowe
% je�li 3:
% a) gabor 32,16, gaborAsym 4, gaborAsym 8
% b) to co 2

%% zrobi� cos innego - co najmniej 2 rodzaje minimalizacji zamiast minEnv6
% a potem podstawi� odpowiedni�funkcj� w mp6 i sprawdzi� co zwraa po
% minimalizacji i jak to si�z sygna�em pokrywa

% TYPE=3;

if TYPE==1
   % fitowanie asymetrycznego gabora2
   
   
   P=fminsearch(@(x) minEnv12(x,signal.*oscillation(time,-omega),time+tmptime1),[0.5/sigma0^2 decay0 mi0],opt);
   
   
   envelope=Asym2Envelope(P,time+tmptime1);
   amplitude=sum(signal.*envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
   miOut=P(3);
   sigmaOut=sqrt(1/2/P(1));
   decayOut=P(2);
   
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
       P=fminsearch(@(x) minEnv12(x,signal.*oscillation(time,-omega),time+tmptime1),P,opt);
       envelope=Asym2Envelope(P,time+tmptime1);
%        miOut=P(3);
%        sigmaOut=sqrt(1/2/P(1));
%        decayOut=P(2);
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

   
elseif TYPE==2 % asym - szuka� kilka asym.
    
    % tu kilka typ�w sprawdzamy!
   TypTest=zeros(1,3);
   % poprawi� wej�cie
   for typ=1:length(TypTest)

       if typ==1
           P(typ).p=fminsearch(@(x) minEnv12(x,signal.*oscillation(time,-omega),time+tmptime1),[1/2/(sigma0/3)^2 10/sigma0 mi0-sigma0],opt);
           P(typ).envelope=Asym2Envelope(P(typ).p,time+tmptime1);
           P(typ).amplitude=sum(signal.*P(typ).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(typ).amplitude);  
       elseif typ==2
           P(typ).p=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,3),[0.75/sigma0^4 decay0 mi0],opt);
           P(typ).envelope=Asym4Envelope(P(typ).p,time+tmptime1);
           P(typ).amplitude=sum(signal.*P(typ).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(typ).amplitude);
       elseif typ==3
           P(typ).p=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,4),[7/8/sigma0^8 decay0 mi0],opt);
           P(typ).envelope=Asym8Envelope5(P(typ).p,time+tmptime1);
           P(typ).amplitude=sum(signal.*P(typ).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(typ).amplitude);       
       end
   end

   [mm Typ]=max(TypTest);
   
   envelope=P(Typ).envelope;
   amplitude=P(Typ).amplitude;
   P=P(Typ).p;
   
   if Typ==1 % poniewa�inna kolejnos� to trzeba pozamienia�...
       Typ=5;
   elseif Typ==2
       Typ=3;
   else
       Typ=4;
   end
   
   
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

       P=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,Typ),P,opt);

       if Typ==3
           envelope=Asym4Envelope(P,time+tmptime1);       
       elseif Typ==4
           envelope=Asym8Envelope5(P,time+tmptime1);
       else
           envelope=Asym2Envelope(P,time+tmptime1);
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
   

else
    
    
   % tu kilka typ�w sprawdzamy!
   TypTest=zeros(1,5);
   % poprawi� wej�cie
   for typ=1:length(TypTest)

       if typ==1
           P(1).p=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,typ),[1/sigma0^16 mi0],opt);
           P(1).envelope=Gabor16Envelope(P(1).p,time+tmptime1);
           P(1).amplitude=sum(signal.*P(1).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(1).amplitude);
%            hold on
%            plot(P(1).envelope,'r')
%            pause
%            miOut=P(1).p(2);
%            sigmaOut=(15/16/P(1).p(1))^(1/16);

       elseif typ==2
           P(2).p=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,typ),[1/sigma0^32 mi0],opt);
           P(2).envelope=Gabor32Envelope(P(2).p,time+tmptime1);
           P(2).amplitude=sum(signal.*P(2).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(2).amplitude);

       elseif typ==3
           P(3).p=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,typ),[0.75/sigma0^4 decay0 mi0],opt);
           P(3).envelope=Asym4Envelope(P(3).p,time+tmptime1);
           P(3).amplitude=sum(signal.*P(3).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(3).amplitude);

       elseif typ==4
           P(4).p=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,typ),[7/8/sigma0^8 decay0 mi0],opt);
           P(4).envelope=Asym8Envelope5(P(4).p,time+tmptime1);
           P(4).amplitude=sum(signal.*P(4).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(4).amplitude);
       else
           P(5).p=fminsearch(@(x) minEnv12(x,signal.*oscillation(time,-omega),time+tmptime1),[1/2/(sigma0/3)^2 10/sigma0 mi0-sigma0],opt);
           P(5).envelope=Asym2Envelope(P(5).p,time+tmptime1);
           P(5).amplitude=sum(signal.*P(5).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(5).amplitude);           
       end
   end
% TypTest
% pause
   [mm Typ]=max(TypTest);

   envelope=P(Typ).envelope;
   amplitude=P(Typ).amplitude;
   P=P(Typ).p;
   
%    miOut=P(3);
%    sigmaOut=sqrt(1/2/P(1));
%    decayOut=P(2);
   
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

   % dostawi� sta�e decay! poprawi� i wybra� rz�dane funkcje, sprawdzi�
   % jakie wyj�cia b�d� dla oblicze�... na pojedynczych atomach... r�nego
   % rodzaju!
   while (abs(amplitude)-mmax)/mmax > epsilon

       mmax=abs(amplitude);

       P=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,Typ),P,opt);

       if Typ==1
           envelope=Gabor16Envelope(P,time+tmptime1);
       elseif Typ==2
           envelope=Gabor32Envelope(P,time+tmptime1);
       elseif Typ==3
           envelope=Asym4Envelope(P,time+tmptime1);       
       elseif Typ==4
           envelope=Asym8Envelope5(P,time+tmptime1);
       else
           envelope=Asym2Envelope(P,time+tmptime1);
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
    
end





%% zbi�r mo�liwych funkcji:

function y=Gabor16Envelope(P,x)
alfa=P(1);
mi=P(2);
y=exp((-alfa*( x-mi).^16 ));
y=y/norm(y);
return

function y=Gabor32Envelope(P,x)
alfa=P(1);
mi=P(2);
y=exp((-alfa*(( x-mi).^32) )) ;
y=y/norm(y);
return

function y=Asym4Envelope(P,x)
c=P(1);
d=P(2);
mi=P(3);
tmp_x_mi=x-mi;
y=exp((-c*( tmp_x_mi).^4 )  ./ (1+ d*( tmp_x_mi) .* (atan(1e16*(tmp_x_mi))+pi/2)/pi));
y=y/norm(y);
return

function y=Asym8Envelope5(P,x)
c=P(1);
d=P(2);
mi=P(3);
tmp_x_mi=x-mi;
y=exp((-c*( tmp_x_mi).^8 )  ./ (1+ d*( tmp_x_mi).^5 .* (atan(1e16*(tmp_x_mi))+pi/2)/pi));
y=y/norm(y);
return

function y=Asym2Envelope(P,x)
c=P(1);
d=P(2);
mi=P(3);
tmp_x_mi=x-mi;
y=exp((-c*( tmp_x_mi).^2 )  ./ (1+ d*(tmp_x_mi) .* (atan(1e16*(tmp_x_mi))+pi/2)/pi));
y=y/norm(y);
return

function err=minEnv12(P,signal,x)

env=Asym2Envelope(P,x);
err=-abs(sum(signal.* env ));
return


function err=minEnv3(P,signal,x,typ)

env=0;
if typ==1
    env=Gabor16Envelope(P,x);
elseif typ==2
    env=Gabor32Envelope(P,x);
elseif typ==3
    env=Asym4Envelope(P,x);
elseif typ==4
   env=Asym8Envelope5(P,x);
else
   env=Asym2Envelope(P,x);%% >> mieni� na inne!
end
% mgauss=exp(-polyval(P,time));
% mgauss=mgauss/norm(mgauss);

err=-abs(sum(signal.* env ));
return


function err=bestOmega(om,signal,time)

tmp=exp(-i*om*time);
err=-abs(sum(signal.*tmp));
return

function z=oscillation(time,omega)

z=exp(i*omega*time);
return

