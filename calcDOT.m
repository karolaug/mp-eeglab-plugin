

function calcDOT(envelope_book,MIN_FFT_N)
global restSIGNAL subMaxDot subMaxFreq env_part

siglen=length(restSIGNAL);
iter=0;
for ii=1:length(envelope_book)
    tmp_step=envelope_book(ii).skok;
    tmp_atom=envelope_book(ii).atom;
    tmp_sr=envelope_book(ii).sr;
    tmp_p=tmp_sr-length(tmp_atom);
    tmp_k=tmp_p+length(tmp_atom);
    
    for jj=0:tmp_step:(siglen+tmp_step)% pozycja
       
        
         % najpierw chcę wybrać fragment obwiedni atomu, który mnie
        % interesuje - na starcie będzie to ogon (od maximum)
        % pod koneic sygnału będzie to front)
        tmp_p=max([(tmp_sr-jj) 1]);%początek wybranej części obwiedni atomu
        tmp_k=min([length(tmp_atom) tmp_sr+siglen-jj-1]);
                tmp1=max([jj-tmp_sr 1]);
        tmp2=tmp1+(tmp_k-tmp_p);
%         [tmp1 tmp2]
        tmp_ind=tmp1:tmp2;
        % wybrana część obwiedni atomu dla danego kroku:
%         env_ind_tmp=tmp_p:tmp_k;
%         ind1=env_ind_tmp;
        iter=iter+1; 
        % najpierw trzeba wyciąć odpowiedni kawałek sygnału!
        % najpierw stworzyć wektor który oznaczy interesujący kawałek
        % sygnału:
%         tmp_ind=tmp_step+tmp_p:(tmp_step+tmp_k-1);
%                 tmp_ind=jj+tmp_p:(jj+tmp_k-1);
%         ind1=find(tmp_ind>0 & tmp_ind<(siglen+1) );
        % te indeksy posłużą do wyjącie odpowiedniego fragmentu atomu
        % natomiast do wyjęcia odpowiedniego fragmentu sygnału:
        % tmp_ind(ind1)
        
%         env_part(iter).envelope=tmp_atom(ind1);
%         env_part(iter).time=tmp_ind(ind1);
%         signal_part=restSIGNAL(tmp_ind(ind1));
        signal_part=restSIGNAL(tmp_ind);
        to_fft=signal_part.*env_part(iter).envelope;
        
        
        nfft=max([length(to_fft) MIN_FFT_N]);
        czestosci=(0:nfft/2)/nfft;
%                 czestosci=[czestosci, czestosci(end-1*mod(nfft+1,2):-1:2)];
        DOT=fft(to_fft,nfft);
        
        [maxDot,mind]=max(abs(DOT(1:length(czestosci))));
        
        subMaxDot(iter)=DOT(mind);
        subMaxFreq(iter)=2*pi*czestosci(mind);
        
    end
end