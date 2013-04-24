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