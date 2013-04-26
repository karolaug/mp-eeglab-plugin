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




function plotMap(time , freqs , xticks , yticks , map , Tlimit , Flimit , NICE)
% plot t-f map
% Copyright Konrad Kwaskiewicz, 2012

global MPmapSettings;

if isempty(xticks)
    xticks=[time(1) time(end/2) time(end)];
end

if isempty(yticks)
    tmpff=min([Flimit(2) freqs(end)]);
    yticks=[freqs(1) round(tmpff/2) tmpff];
end

if isempty(Tlimit)
    Tlimit=[time(1) time(end)];
end

if isempty(Flimit)
    Flimit=[freqs(1) freqs(end)];
end

if NICE==1
    imagesc(time,freqs,map,'Parent',MPmapSettings.mapaxis);
    set(gca,'YDir','default')
else

  surf(time,freqs,map);
  if Tlimit(1)>0 && Flimit(1)>0% skala log
      
      set(gca,'Xscale','log')
      set(gca,'Yscale','log')
  end

  view(2)
  shading interp
  %shading flat
end



set(gca,'XTick',xticks)
set(gca,'XTickLabel',num2cell(xticks*1e0))
set(gca,'YTick',yticks)
set(gca,'YTickLabel',num2cell(yticks/1e0))
set(gca,'fontsize',12,'fontname','arial','linewidth',2)
box on
xlim(Tlimit)
ylim(Flimit)