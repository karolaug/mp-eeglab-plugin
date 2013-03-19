function [out_book, EE]=mp6(signal,envelope_book,MIN_FFT_N,max_iter,minEnergy,dE,GRAD_ON,Fs)

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

% Copyright:
%   Konrad Kwaskiewicz,
%   Tomasz Spustek,
%   2012-2013.

global restSIGNAL subMaxDot subMaxFreq env_part Giteracja
Giteracja = 0;

PrzedM    = [];
PoM       = [];

if size(signal,2)==1
    signal=signal.';
end

if sum(imag(signal))==0
    signal=hilbert(signal);
end

signalRest=(signal);
signalEnergy=Energy((signal));

out_book=[];                                    % indeks envelope_book, pozycja, częstość, rekonstrukcja


siglen=length(signal);

env_part=[];
subMaxDot=[];
subMaxFreq=[];


iter=0;
for ii=1:length(envelope_book)
    tmp_step = envelope_book(ii).skok;
    tmp_atom = envelope_book(ii).atom;
    tmp_sr   = envelope_book(ii).sr;
    
    for jj=0:tmp_step:(siglen+tmp_step)% pozycja
        
        tmp_p=max([(tmp_sr-jj) 1]);                             %początek wybranej części obwiedni atomu
        tmp_k=min([length(tmp_atom) tmp_sr+siglen-jj-1]);       %koniec, jak mniemam
       
        env_ind_tmp = tmp_p:tmp_k;      %indeks po pozycjach od początku do końca
        ind1        = env_ind_tmp;
        
        iter=iter+1;
        
        % indeksy aktualnie rozważanego fragmentu sygnału:
        tmp1    = max([jj-tmp_sr 1]);
        tmp2    = tmp1+(tmp_k-tmp_p);
        tmp_ind = tmp1:tmp2;
        
        if length(ind1)<3
            break
        end
        
        env_part(iter).envelope   = tmp_atom(ind1)/norm(tmp_atom(ind1));
        env_part(iter).time       = tmp_ind;
        env_part(iter).sigma      = envelope_book(ii).sigma;
        env_part(iter).type       = envelope_book(ii).type;
        env_part(iter).decay      = envelope_book(ii).decay;
        
        signal_part = signal(tmp_ind);      % rozważany wycinek sygnału
        
        to_fft = signal_part.*env_part(iter).envelope;
        
        nfft      = max([length(to_fft) MIN_FFT_N]);
        czestosci = (0:nfft/2)/nfft;
        DOT       = fft(to_fft,nfft);
        
        [~,mind]  = max(abs(DOT(1:length(czestosci))));
        
        subMaxDot(iter)  = DOT(mind);                   % TO TUTAJ!
        subMaxFreq(iter) = 2*pi*czestosci(mind);
    end
end


ii=1;                                       %pierwsze maksimum

[~, mmaxInd] = max(abs(subMaxDot));
mmax         = subMaxDot(mmaxInd);

TIME=(1:length(env_part(mmaxInd).time))-1;

out_book(ii).time                              = env_part(mmaxInd).time;
out_book(ii).oscilation                        = subMaxFreq(mmaxInd);
out_book(ii).amplitude                         = mmax;
out_book(ii).sigma                             = mmax;% do ew implementacji
out_book(ii).envelope                          = zeros(1,siglen);
out_book(ii).envelope(out_book(ii).time)       = env_part(mmaxInd).envelope;
out_book(ii).reconstruction                    = zeros(1,siglen);
out_book(ii).reconstruction(out_book(ii).time) = mmax*env_part(mmaxInd).envelope.*exp(1i*out_book(ii).oscilation*TIME);

PrzedM(1+length(PrzedM))  = abs(mmax);
PoM(1+length(PoM))        = abs(mmax);          %abs(out_book(ii).amplitude);


if GRAD_ON
    [~, mi_tmp]     = max(env_part(mmaxInd).envelope);
    mi0             = env_part(mmaxInd).time(mi_tmp);
    sigma0          = env_part(mmaxInd).sigma;
    
    [bestOmega bestAmpl bestEnv bestReconstr miOut sigmaOut] = fitBestAtomGrad((mmax),mi0,sigma0,subMaxFreq(mmaxInd),env_part(mmaxInd).decay,signalRest,env_part(mmaxInd).time(1),env_part(mmaxInd).type);
    
    if abs(bestAmpl) > abs(mmax)
        out_book(ii).oscilation=bestOmega;
        out_book(ii).amplitude=bestAmpl;
        out_book(ii).envelope=bestEnv;
        out_book(ii).reconstruction=bestReconstr;
        out_book(ii).mi=miOut;
        out_book(ii).sigma=sigmaOut;
        PoM(length(PoM))=abs(out_book(ii).amplitude);
    end
    
%     ploting reconstruction
%     subplot(2,1,1)
%     plot(real(signalRest))
%     hold on
%     plot(real(out_book(ii).reconstruction),'r','linewidth',2)
%     hold off
%     title(['Signal and selected atom at iteration:  ', num2str(ii)])
%     subplot( 2,1,2)
%     plot(real(signalRest))
%     hold on
%     plot(real(out_book(ii).reconstruction),'r','linewidth',2)
%     hold off
%     title(['ZOOM', ' freq ' num2str(out_book(ii).oscilation/2/pi*Fs)])
%     xlim([out_book(ii).time(1) out_book(ii).time(end)])
%     drawnow
end

minEnergy  = minEnergy - dE*dot(out_book(ii).reconstruction , out_book(ii).reconstruction)/dot(signalRest,signalRest);
signalRest = signalRest - out_book(ii).reconstruction;

restSIGNAL = signalRest;

EE(ii)     = 1 - Energy(signalRest)/signalEnergy;

disp([  'Iteration: ', num2str(ii), ', Energy explained: ',num2str(EE(ii))  ])      % wypisz feedback


if EE(ii) >minEnergy            % KRYTERIUM STOPU DLA 1-go kroku!
    return
end



for ii=2:max_iter               % pozostałe iteracje
    
    calcDOT(envelope_book , MIN_FFT_N);
    
    
    absDOT       = abs(subMaxDot);
    [~, mmaxInd] = max(absDOT);
    mmax         = subMaxDot(mmaxInd);
    
    TIME         = (1:length(env_part(mmaxInd).time)) - 1;
    
    
    % uzupełnienie atomu zwycięzcy!
    out_book(ii).time                              = env_part(mmaxInd).time;
    out_book(ii).oscilation                        = subMaxFreq(mmaxInd);
    out_book(ii).amplitude                         = mmax;
    out_book(ii).sigma                             = mmax;% do ew implementacji
    out_book(ii).envelope                          = zeros(1,siglen);  
    out_book(ii).envelope(out_book(ii).time)       = env_part(mmaxInd).envelope;
    out_book(ii).reconstruction                    = zeros(1,siglen);
    out_book(ii).reconstruction(out_book(ii).time) = mmax*env_part(mmaxInd).envelope.*exp(1i*out_book(ii).oscilation*TIME);
    
    PrzedM(1+length(PrzedM))   = abs(mmax);
    PoM(1+length(PoM))         = abs(mmax);%abs(out_book(ii).amplitude);
    
    if GRAD_ON
        
        [~, mi_tmp]   = max(env_part(mmaxInd).envelope);
        mi0           = env_part(mmaxInd).time(mi_tmp);
        sigma0        = env_part(mmaxInd).sigma;
        [bestOmega bestAmpl bestEnv bestReconstr miOut sigmaOut] = fitBestAtomGrad((mmax),mi0,sigma0,subMaxFreq(mmaxInd),env_part(mmaxInd).decay,signalRest,env_part(mmaxInd).time(1),env_part(mmaxInd).type);
        
        if abs(bestAmpl) > abs(mmax)
            
            out_book(ii).oscilation      = bestOmega;
            out_book(ii).amplitude       = bestAmpl;
            out_book(ii).envelope        = bestEnv;
            out_book(ii).reconstruction  = bestReconstr;
            out_book(ii).mi              = miOut;
            out_book(ii).sigma           = sigmaOut;
            PoM(length(PoM))             = abs(out_book(ii).amplitude);
        end
        
%         subplot(2,1,1)
%         plot(real(signalRest))
%         hold on
%         plot(real(out_book(ii).reconstruction),'r','linewidth',2)
%         hold off
%         title(['Signal and selected atom at iteration:  ', num2str(ii)])
%         
%         subplot( 2,1,2)
%         plot(real(signalRest))
%         hold on
%         plot(real(out_book(ii).reconstruction),'r','linewidth',2)
%         hold off
%         title(['ZOOM', ' freq ' num2str(out_book(ii).oscilation/2/pi*Fs)])
%         xlim([out_book(ii).time(1) out_book(ii).time(end)])
%         drawnow; 
    end
    
    signalRest   = signalRest-out_book(ii).reconstruction;
    restSIGNAL   = signalRest;
    EE(ii)       = 1-Energy(signalRest)/signalEnergy;
   
    disp([  'Iteration: ', num2str(ii), ', Energy explained: ',num2str(EE(ii))  ])      % wypisz feedback
    
    if EE(ii) > minEnergy           % KRYTERIUM STOPU DLA ii-tego kroku!
        break
    end
    
    restSIGNAL=signalRest;
end




function E = Energy(signal)
    E = sum(signal.*conj(signal));
return
