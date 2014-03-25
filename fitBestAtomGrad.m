%    MP MATLAB plugin
%
%    Copyright (C) 2013 Tomasz Spustek, Konrad Kwaśkiewicz, Karol Auguštin
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%    Tomasz Spustek <tomasz@spustek.pl>
%    Konrad Kwaśkiewicz <konrad.kwaskiewicz@gmail.com>
%    Karol Auguštin <karol@augustin.pl>




function [omega amplitude envelope reconstruction miOut sigmaOut decayOut] = fitBestAtomGrad( mmax,mi0,sigma0,omega,decay0,signal,tmptime1,TYPE,asym)
epsilon=1e-3;
time=1:length(signal);
time=time-tmptime1;
opt=optimset('TolX',epsilon,'TolFun',epsilon);
miOut=mi0;
sigmaOut=sigma0;
decayOut=decay0;

if TYPE==1
   P=fminsearch(@(x) minEnv12(x,signal.*oscillation(time,-omega),time+tmptime1,asym),[0.5/sigma0^2 decay0 mi0],opt);
   envelope=Asym2Envelope(P,time+tmptime1,asym);
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
       P=fminsearch(@(x) minEnv12(x,signal.*oscillation(time,-omega),time+tmptime1,asym),P,opt);
       envelope=Asym2Envelope(P,time+tmptime1,asym);
       amplitude=sum(signal.*envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
       reconstruction=amplitude*envelope.*(oscillation(time,omega));
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
   
elseif TYPE==2
   TypTest=zeros(1,3);

   for typ=1:length(TypTest)
       if typ==1
           P(typ).p=fminsearch(@(x) minEnv12(x,signal.*oscillation(time,-omega),time+tmptime1,asym),[1/2/(sigma0/3)^2 10/sigma0 mi0-sigma0],opt);
           P(typ).envelope=Asym2Envelope(P(typ).p,time+tmptime1,asym);
           P(typ).amplitude=sum(signal.*P(typ).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(typ).amplitude);  
       elseif typ==2
           P(typ).p=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,3,asym),[0.75/sigma0^4 decay0 mi0],opt);
           P(typ).envelope=Asym4Envelope(P(typ).p,time+tmptime1);
           P(typ).amplitude=sum(signal.*P(typ).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(typ).amplitude);
       elseif typ==3
           P(typ).p=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,4,asym),[7/8/sigma0^8 decay0 mi0],opt);
           P(typ).envelope=Asym8Envelope5(P(typ).p,time+tmptime1);
           P(typ).amplitude=sum(signal.*P(typ).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(typ).amplitude);       
       end
   end

   [mm Typ]=max(TypTest);
   envelope=P(Typ).envelope;
   amplitude=P(Typ).amplitude;
   P=P(Typ).p;
   
   if Typ==1
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
       P=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,Typ,asym),P,opt);

       if Typ==3
           envelope=Asym4Envelope(P,time+tmptime1);       
       elseif Typ==4
           envelope=Asym8Envelope5(P,time+tmptime1);
       else
           envelope=Asym2Envelope(P,time+tmptime1,asym);
       end
       amplitude=sum(signal.*envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
       reconstruction=amplitude*envelope.*(oscillation(time,omega));
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
    
    
   TypTest=zeros(1,5);
   for typ=1:length(TypTest)

       if typ==1
           P(1).p=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,typ,asym),[1/sigma0^16 mi0],opt);
           P(1).envelope=Gabor16Envelope(P(1).p,time+tmptime1);
           P(1).amplitude=sum(signal.*P(1).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(1).amplitude);

       elseif typ==2
           P(2).p=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,typ,asym),[1/sigma0^32 mi0],opt);
           P(2).envelope=Gabor32Envelope(P(2).p,time+tmptime1);
           P(2).amplitude=sum(signal.*P(2).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(2).amplitude);

       elseif typ==3
           P(3).p=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,typ,asym),[0.75/sigma0^4 decay0 mi0],opt);
           P(3).envelope=Asym4Envelope(P(3).p,time+tmptime1);
           P(3).amplitude=sum(signal.*P(3).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(3).amplitude);

       elseif typ==4
           P(4).p=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,typ,asym),[7/8/sigma0^8 decay0 mi0],opt);
           P(4).envelope=Asym8Envelope5(P(4).p,time+tmptime1);
           P(4).amplitude=sum(signal.*P(4).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(4).amplitude);

       else
           P(5).p=fminsearch(@(x) minEnv12(x,signal.*oscillation(time,-omega),time+tmptime1,asym),[1/2/(sigma0/3)^2 10/sigma0 mi0-sigma0],opt);
           P(5).envelope=Asym2Envelope(P(5).p,time+tmptime1,asym);
           P(5).amplitude=sum(signal.*P(5).envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
           TypTest(typ)=abs(P(5).amplitude);           
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
       P=fminsearch(@(x) minEnv3(x,signal.*oscillation(time,-omega),time+tmptime1,Typ,asym),P,opt);
       if Typ==1
           envelope=Gabor16Envelope(P,time+tmptime1);
       elseif Typ==2
           envelope=Gabor32Envelope(P,time+tmptime1);
       elseif Typ==3
           envelope=Asym4Envelope(P,time+tmptime1);       
       elseif Typ==4
           envelope=Asym8Envelope5(P,time+tmptime1);
       else
           envelope=Asym2Envelope(P,time+tmptime1,asym);
       end
       amplitude=sum(signal.*envelope.*oscillation(time,-omega));%sum(signal.*gauss(time+tmptime1,mi0,sigma0).*oscillation(time,-omega));
       reconstruction=amplitude*envelope.*(oscillation(time,omega));
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

function y=Asym2Envelope(P,x,asym)     % gives asymetries
c=P(1);
d=P(2);
mi=P(3);
tmp_x_mi=x-mi;
if asym ==1
    y=exp((-c*( tmp_x_mi).^2 )  ./ (1+ d*(tmp_x_mi) .* (atan(1e16*(tmp_x_mi))+pi/2)/pi));
else
    y=exp((-c*( tmp_x_mi).^2 ));
end
y=y/norm(y);
return


% function y=Asym2Envelope(P,x)       % without asymeties
% c=P(1);
% d=P(2);
% mi=P(3);
% tmp_x_mi=x-mi;
% y=exp((-c*( tmp_x_mi).^2 ));
% y=y/norm(y);
% return


function err=minEnv12(P,signal,x,asym)
env=Asym2Envelope(P,x,asym);
err=-abs(sum(signal.* env ));
return


function err=minEnv3(P,signal,x,typ,asym)
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
   env=Asym2Envelope(P,x,asym);
end
err=-abs(sum(signal.* env ));
return


function err=bestOmega(om,signal,time)
tmp=exp(-i*om*time);
err=-abs(sum(signal.*tmp));
return

function z=oscillation(time,omega)
z=exp(i*omega*time);
return
