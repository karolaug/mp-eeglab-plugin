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

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.

%    Tomasz Spustek <tomasz@spustek.pl>
%    Konrad Kwaśkiewicz <konrad.kwaskiewicz@gmail.com>
%    Karol Auguštin <karol@augustin.pl>




function [time2, freqs2, map]=countAmap(book,time,SF,epoch,channel)
% compute t-f map
% book: book containing parameters of atoms to be plotted
% time: indexes of samples
% SF: sampling frequency
% Copyright Konrad Kwaskiewicz, 2012



%% wymiar obrazka
finalFlen=1e3;


len1=length(time);% długość czasu trwania sygnału
finalTlen=min([2e3 len1]);

%czas i częstość w jednostkach rzeczywistych
if len1>finalTlen
    time2=max(time)*linspace(0,1,finalTlen)/SF;
else
    time2=(time(end)-time(1))/SF*linspace(0,1,finalTlen);
end
freqs2=SF/2*linspace(0,1,finalFlen);

map = zeros(finalFlen,finalTlen);   % prepare matrix for a map

siglen=length(time);
time2len=round(siglen*0.05)*4;
winRL=hann(time2len)';
window2smooth=[winRL(1:end/2) ones(1,siglen-time2len) winRL(1+end/2:end)];


X = squeeze(book.reconstruction(1,1,:,:));
Y = book.parameters(epoch,channel);

for ii = 1:size(Y.amplitudes,1)
    atom     = real(X(ii,:));
    env      = Y.envelopes(ii,:) .* abs(Y.amplitudes(ii));

    realYwin = atom.*window2smooth;
    zz       = fft(realYwin);
    z        = abs(zz(1:floor(length(zz)/2+1) ));
    
    z        = halfWidthGauss(z);
    
    z        = resample(z,finalFlen,length(z));
    z        = z/max(z);
    envelope = resample(env,finalTlen,length(env));
    tmp     = z'*envelope;
    map     = map + (tmp);
    
end

function y=halfWidthGauss(z)

[mz mzi]=max(z);

id=find(z(1:mzi)-0.5*mz<0);
if isempty(id)
    L=mzi;%-id(end);
else
    L=mzi-id(end);
end

id=find(z(mzi:end)-0.5*mz<0);
if isempty(id)
    R=z(end);
else
    R=id(1);
end

sigma=(L+R)/2/sqrt(log(4));
t=1:length(z);
y=mz*exp(-(t-mzi).^2/2/sigma^2);
