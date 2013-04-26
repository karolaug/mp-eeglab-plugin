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
        tmp_p=max([(tmp_sr-jj) 1]);%początek wybranej części obwiedni atomu
        tmp_k=min([length(tmp_atom) tmp_sr+siglen-jj-1]);
                tmp1=max([jj-tmp_sr 1]);
        tmp2=tmp1+(tmp_k-tmp_p);
        tmp_ind=tmp1:tmp2;
        iter=iter+1; 
        signal_part=restSIGNAL(tmp_ind);
        to_fft=signal_part.*env_part(iter).envelope;
        
        
        nfft=max([length(to_fft) MIN_FFT_N]);
        czestosci=(0:nfft/2)/nfft;
        DOT=fft(to_fft,nfft);
        [maxDot,mind]=max(abs(DOT(1:length(czestosci))));
        subMaxDot(iter)=DOT(mind);
        subMaxFreq(iter)=2*pi*czestosci(mind);
        
    end
end
