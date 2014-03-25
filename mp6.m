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




function [out_book, EE]=mp6(signal,envelope_book,MIN_FFT_N,max_iter,minEnergy,dE,GRAD_ON,Fs,asym)

% compute decomposition
% input:
% signal: signal to decompose (one channel)
% envelope_book: book of window shapes
% MIN_FFT_N: minimal length of FFT window (used for envelopes shorter than MIN_FFT_N)
% max_iter: maximal number of iterations
% minEnergy: fraction of signal energy to explain
%   decompositions stops when one of the above criterion is met
% dE: 1 - dE is the overlap of structures as measured by common energy
% GRAD_ON: flag to use the gradient optimization for each structure
% Fs: sampling frequency
%%% output:
% out_book: t-f atoms parameters
% EE: freaction of energy explained


global restSIGNAL subMaxDot subMaxFreq env_part Giteracja
Giteracja=0;
PrzedM=[];
PoM=[];

if size(signal,2)==1
    signal=signal.';
end

if sum(imag(signal))==0
    signal=hilbert(signal);
end

signalRest=(signal);
signalEnergy=Energy((signal));
out_book=[];
siglen=length(signal);
env_part=[];
subMaxDot=[];
subMaxFreq=[];
iter=0;
disp 'MP initialization - done';

for ii=1:length(envelope_book)
    tmp_step=envelope_book(ii).skok;
    tmp_atom=envelope_book(ii).atom;
    tmp_sr=envelope_book(ii).sr;
    
    for jj=0:tmp_step:(siglen+tmp_step)
        tmp_p=max([(tmp_sr-jj) 1]);
        tmp_k=min([length(tmp_atom) tmp_sr+siglen-jj-1]);
       
        env_ind_tmp=tmp_p:tmp_k;
        ind1=env_ind_tmp;
        
        iter=iter+1;
        tmp1=max([jj-tmp_sr 1]);
        tmp2=tmp1+(tmp_k-tmp_p);
        tmp_ind=tmp1:tmp2;
        
        if length(ind1)<3
            break
        end
        
        env_part(iter).envelope=tmp_atom(ind1)/norm(tmp_atom(ind1));
        env_part(iter).time=tmp_ind;
        env_part(iter).sigma=envelope_book(ii).sigma;
        env_part(iter).type=envelope_book(ii).type;
        env_part(iter).decay=envelope_book(ii).decay;
        
        signal_part=signal(tmp_ind);
        
        to_fft=signal_part.*env_part(iter).envelope;
        
        nfft=max([length(to_fft) MIN_FFT_N]);
        czestosci=(0:nfft/2)/nfft;
        DOT=fft(to_fft,nfft);
        
        [~,mind]=max(abs(DOT(1:length(czestosci))));
        
        subMaxDot(iter)=DOT(mind);
        subMaxFreq(iter)=2*pi*czestosci(mind);
    end
end


ii=1;
absDOT=abs(subMaxDot);
[~, mmaxInd] = max(absDOT);
mmax=subMaxDot(mmaxInd);
TIME=(1:length(env_part(mmaxInd).time))-1;
out_book(ii).time=env_part(mmaxInd).time;
out_book(ii).oscilation=subMaxFreq(mmaxInd);
out_book(ii).amplitude=mmax;
out_book(ii).sigma=mmax;
out_book(ii).envelope=zeros(1,siglen);
out_book(ii).envelope(out_book(ii).time)=env_part(mmaxInd).envelope;
out_book(ii).reconstruction=zeros(1,siglen);
out_book(ii).reconstruction(out_book(ii).time)=mmax*env_part(mmaxInd).envelope.*exp(1i*out_book(ii).oscilation*TIME);

PrzedM(1+length(PrzedM))=abs(mmax);
PoM(1+length(PoM))=abs(mmax);%abs(out_book(ii).amplitude);


if GRAD_ON,
    [~, mi_tmp]=max(env_part(mmaxInd).envelope);
    mi0=env_part(mmaxInd).time(mi_tmp);
    sigma0=env_part(mmaxInd).sigma;
    
    [bestOmega bestAmpl bestEnv bestReconstr miOut sigmaOut]=fitBestAtomGrad((mmax),mi0,sigma0,subMaxFreq(mmaxInd),env_part(mmaxInd).decay,signalRest,env_part(mmaxInd).time(1),env_part(mmaxInd).type,asym);
    if abs(bestAmpl)>abs(mmax)
        out_book(ii).oscilation=bestOmega;
        out_book(ii).amplitude=bestAmpl;
        out_book(ii).envelope=bestEnv;
        out_book(ii).reconstruction=bestReconstr;
        out_book(ii).mi=miOut;
        out_book(ii).sigma=sigmaOut;
        PoM(length(PoM))=abs(out_book(ii).amplitude);
    end
end

minEnergy=minEnergy-dE*dot(out_book(ii).reconstruction,out_book(ii).reconstruction)/dot(signalRest,signalRest);
signalRest=signalRest-out_book(ii).reconstruction;
restSIGNAL=signalRest;
EE(ii)=1-( Energy(signalRest) )/signalEnergy;
disp(['iteration ', num2str(ii), ', Energy explained: ',num2str(EE(ii))  ])
if EE(ii) >minEnergy
    return
end
disp 'First iteration - done';

for ii=2:max_iter
    calcDOT(envelope_book,MIN_FFT_N);
    absDOT=abs(subMaxDot);
    [~, mmaxInd] = max(absDOT);
    mmax=subMaxDot(mmaxInd);
    TIME=(1:length(env_part(mmaxInd).time))-1;
    out_book(ii).time=env_part(mmaxInd).time;
    out_book(ii).oscilation=subMaxFreq(mmaxInd);
    out_book(ii).amplitude=mmax;
    out_book(ii).sigma=mmax;% do ew implementacji
    out_book(ii).envelope=zeros(1,siglen);  
    out_book(ii).envelope(out_book(ii).time)=env_part(mmaxInd).envelope;
    out_book(ii).reconstruction=zeros(1,siglen);
    out_book(ii).reconstruction(out_book(ii).time)=mmax*env_part(mmaxInd).envelope.*exp(1i*out_book(ii).oscilation*TIME);
    PrzedM(1+length(PrzedM))=abs(mmax);
    PoM(1+length(PoM))=abs(mmax);%abs(out_book(ii).amplitude);

    if GRAD_ON,
        [~, mi_tmp]=max(env_part(mmaxInd).envelope);
        mi0=env_part(mmaxInd).time(mi_tmp);
        sigma0=env_part(mmaxInd).sigma;
        [bestOmega bestAmpl bestEnv bestReconstr miOut sigmaOut]=fitBestAtomGrad((mmax),mi0,sigma0,subMaxFreq(mmaxInd),env_part(mmaxInd).decay,signalRest,env_part(mmaxInd).time(1),env_part(mmaxInd).type,asym);
        if abs(bestAmpl)>abs(mmax)
            out_book(ii).oscilation=bestOmega;
            out_book(ii).amplitude=bestAmpl;
            out_book(ii).envelope=bestEnv;
            out_book(ii).reconstruction=bestReconstr;
            out_book(ii).mi=miOut;
            out_book(ii).sigma=sigmaOut;
            PoM(length(PoM))=abs(out_book(ii).amplitude);
        end
    end
    signalRest=signalRest-out_book(ii).reconstruction;
    restSIGNAL=signalRest;
    EE(ii)=1-Energy(signalRest)/signalEnergy;% wytłumaczona energia
   
    disp(['iteration ', num2str(ii), ', Energy explained: ',num2str(EE(ii))  ])
    if EE(ii) > minEnergy
        break
    end
    restSIGNAL=signalRest;
end

function E=Energy(signal)
E=sum(signal.*conj(signal));
return
