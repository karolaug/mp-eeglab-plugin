function view_mp_maps(map_string)

global MPmapSettings;
global EEG;

if strcmp(map_string,'new_plot')
    MPmapSettings = [];
    MPmapSettings.title = 'Inspect time - frequency maps -- view_mp_maps()';
    MPmapSettings.position = [50 50 800 500];

    MPmapSettings.trialstag = 1;
    MPmapSettings.channelstag = 1;
    MPmapSettings.atomstag = 1;

    MPmapSettings.color = [1 1 1];
    
    MPmapSettings.figure = figure('UserData', MPmapSettings,...
      'Color', MPmapSettings.color, 'Toolbar' , 'figure' , 'name', MPmapSettings.title,...
      'MenuBar','none','Position',MPmapSettings.position, ...
      'numbertitle', 'off', 'visible', 'on');

    % positions of controlls for epochs scrolling
    posepoch = zeros(4,4);
    posepoch(1,:) = [ 0.8500    0.8000    0.0300    0.0300 ]; % < - button
    posepoch(3,:) = [ 0.8900    0.8000    0.0500    0.0300 ]; % [ - text window
    posepoch(2,:) = [ 0.9500    0.8000    0.0300    0.0300 ]; % > - button
    posepoch(4,:) = [ 0.8500    0.8500    0.1000    0.0300 ]; % _ - label
    % creation of epoch-controlls:
    MPmapSettings.e = zeros(4,1);
    MPmapSettings.e(1) = uicontrol('Parent',MPmapSettings.figure, ...
        'Units', 'normalized', ...
        'Position', posepoch(1,:), ...
        'Tag','epoch_button_left',...
        'string','<',...
        'Callback','view_mp_maps(''epoch_step_left'')');
    MPmapSettings.e(2) = uicontrol('Parent',MPmapSettings.figure, ...
        'Units', 'normalized', ...
        'Position', posepoch(2,:), ...
        'Tag','epoch_button_right',...
        'string','>',...
        'Callback','view_mp_maps(''epoch_step_right'')');
    MPmapSettings.e(3) = uicontrol('Parent',MPmapSettings.figure, ...
        'Units', 'normalized', ...
        'BackgroundColor',[1 1 1], ...
        'Position', posepoch(3,:), ...
        'Style','edit', ...
        'Tag','epoch_text',...
        'string', MPmapSettings.trialstag);
    MPmapSettings.e(4) = uicontrol('Parent',MPmapSettings.figure, ...
        'Style','text', ...
        'Units', 'normalized', ...
        'Position', posepoch(4,:), ...
        'Tag','epoch_button_label',...
        'string','Epoch');
    % positions of controlls for channels scrolling
    poschan = zeros(4,4);
    poschan(1,:) = [ 0.8500    0.7000    0.0300    0.0300 ]; % < - button
    poschan(3,:) = [ 0.8900    0.7000    0.0500    0.0300 ]; % [ - text window
    poschan(2,:) = [ 0.9500    0.7000    0.0300    0.0300 ]; % > - button
    poschan(4,:) = [ 0.8500    0.7500    0.1000    0.0300 ]; % _ - label
    % creation of channel-controlls:
    MPmapSettings.ch = zeros(4,1);
    MPmapSettings.ch(1) = uicontrol('Parent',MPmapSettings.figure, ...
        'Units', 'normalized', ...
        'Position', poschan(1,:), ...
        'Tag','epoch_button_left',...
        'string','<',...
        'Callback','view_mp_maps(''chan_step_left'')');
    MPmapSettings.ch(2) = uicontrol('Parent',MPmapSettings.figure, ...
        'Units', 'normalized', ...
        'Position', poschan(2,:), ...
        'Tag','epoch_button_right',...
        'string','>',...
        'Callback','view_mp_maps(''chan_step_right'')');
    MPmapSettings.ch(3) = uicontrol('Parent',MPmapSettings.figure, ...
        'Units', 'normalized', ...
        'BackgroundColor',[1 1 1], ...
        'Position', poschan(3,:), ...
        'Style','edit', ...
        'Tag','epoch_text',...
        'string', MPmapSettings.channelstag);
    MPmapSettings.ch(4) = uicontrol('Parent',MPmapSettings.figure, ...
        'Style','text', ...
        'Units', 'normalized', ...
        'Position', poschan(4,:), ...
        'Tag','channel_button_label',...
        'string','Channel');

    MPmapSettings.mapaxis    = axes('outerposition',[.0  .4  .8  .6]);
    refresh_map();
        
    MPmapSettings.signalaxis = axes('outerposition',[.0  .1  .8  .3]);
    refresh_signal();
    
elseif strcmp(map_string,'epoch_step_right')
    if MPmapSettings.trialstag == size(EEG.book.epoch_labels,2)
        disp 'No further epochs';
    else
        disp 'Displaying next epoch'
        MPmapSettings.trialstag = MPmapSettings.trialstag + 1;
        refresh_map();
        refresh_signal();
    end
elseif strcmp(map_string,'epoch_step_left')
    if MPmapSettings.trialstag == 1
        disp 'No previous epochs';
    else
        disp 'Displaying previous epoch'
        MPmapSettings.trialstag = MPmapSettings.trialstag - 1;
        refresh_map();
        refresh_signal();
    end
elseif strcmp(map_string,'chan_step_right')
    if MPmapSettings.channelstag == size(EEG.book.channel_labels,2)
        disp 'No further channels';
    else
        disp 'Displaying next channel'
        MPmapSettings.channelstag = MPmapSettings.channelstag + 1;
        refresh_map();
        refresh_signal();
    end
elseif strcmp(map_string,'chan_step_left')
    if MPmapSettings.channelstag == 1
        disp 'No previous channels';
    else
        disp 'Displaying previous channel'
        MPmapSettings.channelstag = MPmapSettings.channelstag - 1;
        refresh_map();
        refresh_signal();
    end
end

end



function refresh_map()
    global MPmapSettings;
    global EEG;
    [time , freqs , map] = countAmap2(EEG.book , 1:EEG.pnts , EEG.srate , MPmapSettings.trialstag , MPmapSettings.channelstag);
    plotMap(time,freqs,[],[],abs((map)),[],[0 EEG.srate/2],1);
    title(MPmapSettings.mapaxis , 'Time - Frequency map');
end

function refresh_signal()
    global MPmapSettings;
    global EEG;
    X = squeeze(EEG.book.reconstruction(MPmapSettings.trialstag,MPmapSettings.channelstag,:,:));
    plot(sum(real(X),1),'b','Parent',MPmapSettings.signalaxis);
    title(MPmapSettings.signalaxis,'Signal reconstruction');
    Xlim(MPmapSettings.signalaxis,[1 EEG.pnts]);
    
    set(MPmapSettings.e(3) ,'String',num2str(EEG.book.epoch_labels(MPmapSettings.trialstag)));
    set(MPmapSettings.ch(3),'String',num2str(EEG.book.channel_labels{MPmapSettings.channelstag}));
end