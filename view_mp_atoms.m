function view_mp_atoms(check_string)


global MPsettings;
global EEG;


if strcmp(check_string,'new_plot')
    MPsettings = [];
    MPsettings.tag = 'blablabla';
    MPsettings.title = 'Inspect single atoms -- view_mp_atoms()';
    MPsettings.position = [50 50 800 500];

    MPsettings.trialstag = 1;
    MPsettings.channelstag = 1;
    MPsettings.atomstag = 1;

    MPsettings.color = [1 1 1];
    
    
    MPsettings.figure = figure('UserData', MPsettings,...
      'Color', MPsettings.color, 'Toolbar' , 'figure' , 'name', MPsettings.title,...
      'MenuBar','none','tag', MPsettings.tag ,'Position',MPsettings.position, ...
      'numbertitle', 'off', 'visible', 'on');

    % positions of controlls for epochs scrolling
    posepoch = zeros(4,4);
    posepoch(1,:) = [ 0.8500    0.8000    0.0300    0.0300 ]; % < - button
    posepoch(3,:) = [ 0.8900    0.8000    0.0500    0.0300 ]; % [ - text window
    posepoch(2,:) = [ 0.9500    0.8000    0.0300    0.0300 ]; % > - button
    posepoch(4,:) = [ 0.8500    0.8500    0.1000    0.0300 ]; % _ - label
    % creation of epoch-controlls:
    MPsettings.e = zeros(4,1);
    MPsettings.e(1) = uicontrol('Parent',MPsettings.figure, ...
        'Units', 'normalized', ...
        'Position', posepoch(1,:), ...
        'Tag','epoch_button_left',...
        'string','<',...
        'Callback','view_mp_atoms(''epoch_step_left'')');
    MPsettings.e(2) = uicontrol('Parent',MPsettings.figure, ...
        'Units', 'normalized', ...
        'Position', posepoch(2,:), ...
        'Tag','epoch_button_right',...
        'string','>',...
        'Callback','view_mp_atoms(''epoch_step_right'')');
    MPsettings.e(3) = uicontrol('Parent',MPsettings.figure, ...
        'Units', 'normalized', ...
        'BackgroundColor',[1 1 1], ...
        'Position', posepoch(3,:), ...
        'Style','edit', ...
        'Tag','epoch_text',...
        'string', MPsettings.trialstag);
    MPsettings.e(4) = uicontrol('Parent',MPsettings.figure, ...
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
    MPsettings.ch = zeros(4,1);
    MPsettings.ch(1) = uicontrol('Parent',MPsettings.figure, ...
        'Units', 'normalized', ...
        'Position', poschan(1,:), ...
        'Tag','epoch_button_left',...
        'string','<',...
        'Callback','view_mp_atoms(''chan_step_left'')');
    MPsettings.ch(2) = uicontrol('Parent',MPsettings.figure, ...
        'Units', 'normalized', ...
        'Position', poschan(2,:), ...
        'Tag','epoch_button_right',...
        'string','>',...
        'Callback','view_mp_atoms(''chan_step_right'')');
    MPsettings.ch(3) = uicontrol('Parent',MPsettings.figure, ...
        'Units', 'normalized', ...
        'BackgroundColor',[1 1 1], ...
        'Position', poschan(3,:), ...
        'Style','edit', ...
        'Tag','epoch_text',...
        'string', MPsettings.channelstag);
    MPsettings.ch(4) = uicontrol('Parent',MPsettings.figure, ...
        'Style','text', ...
        'Units', 'normalized', ...
        'Position', poschan(4,:), ...
        'Tag','channel_button_label',...
        'string','Channel');
    % positions of controlls for atoms scrolling
    posatom = zeros(4,4);
    posatom(1,:) = [ 0.8500    0.2000    0.0300    0.0300 ]; % < - button
    posatom(3,:) = [ 0.8900    0.2000    0.0500    0.0300 ]; % [ - text window
    posatom(2,:) = [ 0.9500    0.2000    0.0300    0.0300 ]; % > - button
    posatom(4,:) = [ 0.8500    0.2500    0.1000    0.0300 ]; % _ - label
    % creation of atom-controlls:
    MPsettings.a = zeros(4,1);
    MPsettings.a(1) = uicontrol('Parent',MPsettings.figure, ...
        'Units', 'normalized', ...
        'Position', posatom(1,:), ...
        'Tag','epoch_button_left',...
        'string','<',...
        'Callback','view_mp_atoms(''atom_step_left'')');
    MPsettings.a(2) = uicontrol('Parent',MPsettings.figure, ...
        'Units', 'normalized', ...
        'Position', posatom(2,:), ...
        'Tag','epoch_button_right',...
        'string','>',...
        'Callback','view_mp_atoms(''atom_step_right'')');
    MPsettings.a(3) = uicontrol('Parent',MPsettings.figure, ...
        'Units', 'normalized', ...
        'BackgroundColor',[1 1 1], ...
        'Position', posatom(3,:), ...
        'Style','edit', ...
        'Tag','epoch_text',...
        'string', MPsettings.atomstag);
     MPsettings.a(4) = uicontrol('Parent',MPsettings.figure, ...
        'Style','text', ...
        'Units', 'normalized', ...
        'Position', posatom(4,:), ...
        'Tag','atom_button_label',...
        'string','Atom');
    
    
    MPsettings.originalaxis = axes('outerposition',[.0  .7  .8  .3]);
        plot(EEG.data(MPsettings.trialstag,:,MPsettings.channelstag),'b');
        title('Original signal');
        MPsettings.yaxlimits=get(MPsettings.originalaxis,'YLim');
        
    MPsettings.reconstructaxis = axes('outerposition',[.0  .4  .8  .3]);
        X = squeeze(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,:,:));
        plot(sum(real(X),1),'b');
        title('Signal reconstruction');
        set(MPsettings.reconstructaxis,'YLim',MPsettings.yaxlimits);
        
    MPsettings.atomaxis = axes('outerposition',[.0  .1  .8  .3]);
        plot(squeeze(real(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,MPsettings.atomstag,:))),'b');
        title('Reconstructing functions');
        set(MPsettings.atomaxis,'YLim',MPsettings.yaxlimits);

        
        
elseif strcmp(check_string, 'epoch_step_left')
    if MPsettings.trialstag == 1
        disp 'No previous epochs';
    else
        disp 'Displaying previous epoch'
        MPsettings.trialstag = MPsettings.trialstag - 1;
        set(MPsettings.e(3),'String',num2str(EEG.book.epoch_labels(MPsettings.trialstag)));
        
        plot(EEG.data(MPsettings.channelstag,:,MPsettings.trialstag),'Parent',MPsettings.originalaxis);
        title(MPsettings.originalaxis,'Original signal');
        MPsettings.yaxlimits=get(MPsettings.originalaxis,'YLim');
        
        try
            plot(squeeze(real(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,MPsettings.atomstag,:))),'b','Parent',MPsettings.atomaxis);
            set(MPsettings.atomaxis,'YLim',MPsettings.yaxlimits);
            title(MPsettings.atomaxis,'Reconstructing functions');
        catch
            MPsettings.atomstag = 1;
            plot(squeeze(real(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,MPsettings.atomstag,:))),'b','Parent',MPsettings.atomaxis);
            set(MPsettings.atomaxis,'YLim',MPsettings.yaxlimits);
            title(MPsettings.atomaxis,'Reconstructing functions');
        end
        
        X = squeeze(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,:,:));
        plot(sum(real(X),1),'b','Parent',MPsettings.reconstructaxis);
        title(MPsettings.reconstructaxis,'Signal reconstruction');
        set(MPsettings.reconstructaxis,'YLim',MPsettings.yaxlimits);
        
        
    end
    
elseif strcmp(check_string, 'epoch_step_right')
    if MPsettings.trialstag == size(EEG.book.epoch_labels,2)
        disp 'No further epochs';
    else
        disp 'Displaying next epoch'
        MPsettings.trialstag = MPsettings.trialstag + 1;
        set(MPsettings.e(3),'String',num2str(EEG.book.epoch_labels(MPsettings.trialstag)));
        
        plot(EEG.data(MPsettings.channelstag,:,MPsettings.trialstag),'Parent',MPsettings.originalaxis);
        title(MPsettings.originalaxis,'Original signal');
        MPsettings.yaxlimits=get(MPsettings.originalaxis,'YLim');     
        
        try
            plot(squeeze(real(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,MPsettings.atomstag,:))),'b','Parent',MPsettings.atomaxis);
            set(MPsettings.atomaxis,'YLim',MPsettings.yaxlimits);
            title(MPsettings.atomaxis,'Reconstructing functions');
        catch
            MPsettings.atomstag = 1;
            plot(squeeze(real(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,MPsettings.atomstag,:))),'b','Parent',MPsettings.atomaxis);
            set(MPsettings.atomaxis,'YLim',MPsettings.yaxlimits);
            title(MPsettings.atomaxis,'Reconstructing functions');
        end
        
        X = squeeze(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,:,:));
        plot(sum(real(X),1),'b','Parent',MPsettings.reconstructaxis);
        title(MPsettings.reconstructaxis,'Signal reconstruction');
        set(MPsettings.reconstructaxis,'YLim',MPsettings.yaxlimits);
        
        
    end
    
elseif strcmp(check_string, 'chan_step_left')
    if MPsettings.channelstag == 1
        disp 'No previous channels';
    else
        disp 'Displaying previous channel'
        MPsettings.channelstag = MPsettings.channelstag - 1;
        set(MPsettings.ch(3),'String',num2str(EEG.book.channel_labels{MPsettings.channelstag}));
        
        plot(EEG.data(MPsettings.channelstag,:,MPsettings.trialstag),'Parent',MPsettings.originalaxis);
        title(MPsettings.originalaxis,'Original signal');
        MPsettings.yaxlimits=get(MPsettings.originalaxis,'YLim');
        
        try
            plot(squeeze(real(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,MPsettings.atomstag,:))),'b','Parent',MPsettings.atomaxis);
            set(MPsettings.atomaxis,'YLim',MPsettings.yaxlimits);
            title(MPsettings.atomaxis,'Reconstructing functions');
        catch
            MPsettings.atomstag = 1;
            plot(squeeze(real(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,MPsettings.atomstag,:))),'b','Parent',MPsettings.atomaxis);
            set(MPsettings.atomaxis,'YLim',MPsettings.yaxlimits);
            title(MPsettings.atomaxis,'Reconstructing functions');
        end
        
        X = squeeze(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,:,:));
        plot(sum(real(X),1),'b','Parent',MPsettings.reconstructaxis);
        title(MPsettings.reconstructaxis,'Signal reconstruction');
        set(MPsettings.reconstructaxis,'YLim',MPsettings.yaxlimits);
        
        
    end
        
elseif strcmp(check_string, 'chan_step_right')
    if MPsettings.channelstag == size(EEG.book.channel_labels,2)
        disp 'No further channels';
    else
        disp 'Displaying next channel'
        MPsettings.channelstag = MPsettings.channelstag + 1;
        set(MPsettings.ch(3),'String',num2str(EEG.book.channel_labels{MPsettings.channelstag}));
        
        plot(EEG.data(MPsettings.channelstag,:,MPsettings.trialstag),'Parent',MPsettings.originalaxis);
        title(MPsettings.originalaxis,'Original signal');
        MPsettings.yaxlimits=get(MPsettings.originalaxis,'YLim');   
        
        try
            plot(squeeze(real(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,MPsettings.atomstag,:))),'b','Parent',MPsettings.atomaxis);
            set(MPsettings.atomaxis,'YLim',MPsettings.yaxlimits);
            title(MPsettings.atomaxis,'Reconstructing functions');
        catch
            MPsettings.atomstag = 1;
            plot(squeeze(real(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,MPsettings.atomstag,:))),'b','Parent',MPsettings.atomaxis);
            set(MPsettings.atomaxis,'YLim',MPsettings.yaxlimits);
            title(MPsettings.atomaxis,'Reconstructing functions');
        end
        
        X = squeeze(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,:,:));
        plot(sum(real(X),1),'b','Parent',MPsettings.reconstructaxis);
        title(MPsettings.reconstructaxis,'Signal reconstruction');
        set(MPsettings.reconstructaxis,'YLim',MPsettings.yaxlimits);
        
      
    end
    
elseif strcmp(check_string, 'atom_step_left')
    if MPsettings.atomstag == 1
        disp 'No previous atoms';
    else
        disp 'Displaying previous atom'
        MPsettings.atomstag = MPsettings.atomstag - 1;
        set(MPsettings.a(3),'String',num2str(MPsettings.atomstag));
        plot(squeeze(real(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,MPsettings.atomstag,:))),'b','Parent',MPsettings.atomaxis);
        set(MPsettings.atomaxis,'YLim',MPsettings.yaxlimits);
        title(MPsettings.atomaxis,'Reconstructing functions');
    end
    
elseif strcmp(check_string, 'atom_step_right')
    if MPsettings.atomstag == size(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,:,:),3) || real(sum(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,MPsettings.atomstag+1,:),4))==0
        disp 'No further atoms';
    else
        disp 'Displaying next atom'
        MPsettings.atomstag = MPsettings.atomstag + 1;
        set(MPsettings.a(3),'String',num2str(MPsettings.atomstag));
        plot(squeeze(real(EEG.book.reconstruction(MPsettings.trialstag,MPsettings.channelstag,MPsettings.atomstag,:))),'b','Parent',MPsettings.atomaxis);
        set(MPsettings.atomaxis,'YLim',MPsettings.yaxlimits);
        title(MPsettings.atomaxis,'Reconstructing functions');
    end
    
    
end

end