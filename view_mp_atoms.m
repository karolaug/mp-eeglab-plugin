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




function view_mp_atoms(check_string)

global MPatomSettings;
global EEG;

if strcmp(check_string,'new_plot')
    
    if ~isfield(EEG, 'book') || isempty(EEG.book)
        throw(MException('MatchingPursuit:view_mp_atoms','You should calculate MP first.'));
    end
    
    MPatomSettings = [];
    MPatomSettings.title = 'Inspect signal reconstruction and single reconstructing atoms -- view_mp_atoms()';
    MPatomSettings.position = [50 50 800 500];
    MPatomSettings.trialstag = 1;
    MPatomSettings.channelstag = 1;
    MPatomSettings.atomstag = 1;
    MPatomSettings.color = [1 1 1];
    MPatomSettings.time = [1:EEG.pnts] / EEG.srate;
    MPatomSettings.figure = figure('UserData', MPatomSettings,...
      'Color', MPatomSettings.color, 'Toolbar' , 'figure' , 'name', MPatomSettings.title,...
      'MenuBar','none','Position',MPatomSettings.position, ...
      'numbertitle', 'off', 'visible', 'on');
    % positions of controlls for epochs scrolling
    posepoch = zeros(4,4);
    posepoch(1,:) = [ 0.8500    0.8000    0.0300    0.0300 ]; % < - button
    posepoch(3,:) = [ 0.8900    0.8000    0.0500    0.0300 ]; % [ - text window
    posepoch(2,:) = [ 0.9500    0.8000    0.0300    0.0300 ]; % > - button
    posepoch(4,:) = [ 0.8500    0.8500    0.1000    0.0300 ]; % _ - label
    % creation of epoch-controlls:
    MPatomSettings.e = zeros(4,1);
    MPatomSettings.e(1) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'Position', posepoch(1,:), ...
        'Tag','epoch_button_left',...
        'string','<',...
        'Callback','view_mp_atoms(''epoch_step_left'')');
    MPatomSettings.e(2) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'Position', posepoch(2,:), ...
        'Tag','epoch_button_right',...
        'string','>',...
        'Callback','view_mp_atoms(''epoch_step_right'')');
    MPatomSettings.e(3) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'BackgroundColor',[1 1 1], ...
        'Position', posepoch(3,:), ...
        'Style','edit', ...
        'Tag','epoch_text',...
        'string', num2str(EEG.book.epoch_labels(1)));
    MPatomSettings.e(4) = uicontrol('Parent',MPatomSettings.figure, ...
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
    MPatomSettings.ch = zeros(4,1);
    MPatomSettings.ch(1) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'Position', poschan(1,:), ...
        'Tag','epoch_button_left',...
        'string','<',...
        'Callback','view_mp_atoms(''chan_step_left'')');
    MPatomSettings.ch(2) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'Position', poschan(2,:), ...
        'Tag','epoch_button_right',...
        'string','>',...
        'Callback','view_mp_atoms(''chan_step_right'')');
    MPatomSettings.ch(3) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'BackgroundColor',[1 1 1], ...
        'Position', poschan(3,:), ...
        'Style','edit', ...
        'Tag','epoch_text',...
        'string', EEG.book.channel_labels{1});
    MPatomSettings.ch(4) = uicontrol('Parent',MPatomSettings.figure, ...
        'Style','text', ...
        'Units', 'normalized', ...
        'Position', poschan(4,:), ...
        'Tag','channel_button_label',...
        'string','Channel');
    % positions of a frame with parameters of atoms
    posframe = zeros(1,4);
    posframe(1,:) = [ 0.7500    0.1000    0.2300    0.4400 ]; % [] - frame
    posparam = zeros(6,4);
    posparam(1,:) = [ 0.1000    0.9000    0.8000    0.1000 ]; % - amplitude label
    posparam(2,:) = [ 0.2000    0.7500    0.7000    0.1000 ]; % - amplitude text
    posparam(3,:) = [ 0.1000    0.6000    0.8000    0.1000 ]; % - width label
    posparam(4,:) = [ 0.2000    0.4500    0.7000    0.1000 ]; % - width text
    posparam(5,:) = [ 0.1000    0.3000    0.8000    0.1000 ]; % - frequency label
    posparam(6,:) = [ 0.2000    0.1500    0.7000    0.1000 ]; % - frequency text
    MPatomSettings.f = zeros(7,1);
    MPatomSettings.f(1) = uipanel('Title','Atom parameters:','FontSize',12,...
             'BackgroundColor','white',...
             'Position',posframe(1,:));       
    MPatomSettings.f(2) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(1,:), ...
        'Tag','atom_amplitude_label',...
        'string','Amplitude:');
    MPatomSettings.f(3) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(2,:), ...
        'Tag','atom_amplitude_text',...
        'string','p_t');
    MPatomSettings.f(4) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(3,:), ...
        'Tag','atom_width_label',...
        'string','Width:');
    MPatomSettings.f(5) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(4,:), ...
        'Tag','atom_width_text',...
        'string','w_t');
    MPatomSettings.f(6) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(5,:), ...
        'Tag','atom_frequency_label',...
        'string','Frequency:');
    MPatomSettings.f(7) = uicontrol('Parent',MPatomSettings.f(1), ...
        'Style','text', ...
        'Units', 'normalized', ...
        'BackgroundColor','white',...
        'Position', posparam(6,:), ...
        'Tag','atom_frequency_text',...
        'string','f_t');
    % positions of controlls for atoms scrolling
    posatom = zeros(4,4);
    posatom(1,:) = [ 0.8500    0.5500    0.0300    0.0300 ]; % < - button
    posatom(3,:) = [ 0.8900    0.5500    0.0500    0.0300 ]; % [ - text window
    posatom(2,:) = [ 0.9500    0.5500    0.0300    0.0300 ]; % > - button
    posatom(4,:) = [ 0.8500    0.6000    0.1000    0.0300 ]; % _ - label
    % creation of atom-controlls:
    MPatomSettings.a = zeros(4,1);
    MPatomSettings.a(1) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'Position', posatom(1,:), ...
        'Tag','epoch_button_left',...
        'string','<',...
        'Callback','view_mp_atoms(''atom_step_left'')');
    MPatomSettings.a(2) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'Position', posatom(2,:), ...
        'Tag','epoch_button_right',...
        'string','>',...
        'Callback','view_mp_atoms(''atom_step_right'')');
    MPatomSettings.a(3) = uicontrol('Parent',MPatomSettings.figure, ...
        'Units', 'normalized', ...
        'BackgroundColor',[1 1 1], ...
        'Position', posatom(3,:), ...
        'Style','edit', ...
        'Tag','epoch_text',...
        'string', MPatomSettings.atomstag);
     MPatomSettings.a(4) = uicontrol('Parent',MPatomSettings.figure, ...
        'Style','text', ...
        'Units', 'normalized', ...
        'Position', posatom(4,:), ...
        'Tag','atom_button_label',...
        'string','Atom');
    MPatomSettings.originalaxis = axes('outerposition',[.0  .7  .8  .3]);
        plot_original();
    MPatomSettings.reconstructaxis = axes('outerposition',[.0  .4  .8  .3]);
        plot_reconstruct();
    MPatomSettings.atomaxis = axes('outerposition',[.0  .1  .8  .3]);
        plot_atom();
        refresh_atom_parameters();
        
elseif strcmp(check_string, 'epoch_step_left')
    if MPatomSettings.trialstag == 1
        disp 'No previous epochs';
    else
        disp 'Displaying previous epoch'
        MPatomSettings.trialstag = MPatomSettings.trialstag - 1;
        set(MPatomSettings.e(3),'String',num2str(EEG.book.epoch_labels(MPatomSettings.trialstag)));
        if any(EEG.book.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag,:)~=0) == 0 
            MPatomSettings.atomstag = 1;
            set(MPatomSettings.a(3),'String',num2str(MPatomSettings.atomstag));
        end
        plot_original();
        plot_reconstruct();
        plot_atom();
        refresh_atom_parameters();
    end 
elseif strcmp(check_string, 'epoch_step_right')
    if MPatomSettings.trialstag == size(EEG.book.epoch_labels,2)
        disp 'No further epochs';
    else
        disp 'Displaying next epoch'
        MPatomSettings.trialstag = MPatomSettings.trialstag + 1;
        set(MPatomSettings.e(3),'String',num2str(EEG.book.epoch_labels(MPatomSettings.trialstag)));
        if any(EEG.book.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag,:)~=0) == 0 
            MPatomSettings.atomstag = 1;
        end
        plot_original();
        plot_reconstruct();
        plot_atom();
        refresh_atom_parameters();
    end  
elseif strcmp(check_string, 'chan_step_left')
    if MPatomSettings.channelstag == 1
        disp 'No previous channels';
    else
        disp 'Displaying previous channel'
        MPatomSettings.channelstag = MPatomSettings.channelstag - 1;
        set(MPatomSettings.ch(3),'String',num2str(EEG.book.channel_labels{MPatomSettings.channelstag}));
        if any(EEG.book.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag+1,:)~=0) == 0 
            MPatomSettings.atomstag = 1;
        end
        plot_original();
        plot_reconstruct();
        plot_atom();
        refresh_atom_parameters();
    end    
elseif strcmp(check_string, 'chan_step_right')
    if MPatomSettings.channelstag == size(EEG.book.channel_labels,2)
        disp 'No further channels';
    else
        disp 'Displaying next channel'
        MPatomSettings.channelstag = MPatomSettings.channelstag + 1;
        set(MPatomSettings.ch(3),'String',num2str(EEG.book.channel_labels{MPatomSettings.channelstag}));  
        if any(EEG.book.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag+1,:)~=0) == 0 
            MPatomSettings.atomstag = 1;
        end
        plot_original();
        plot_reconstruct();
        plot_atom();
        refresh_atom_parameters();
    end
elseif strcmp(check_string, 'atom_step_left')
    if MPatomSettings.atomstag == 1
        disp 'No previous atoms';
    else
        disp 'Displaying previous atom'
        MPatomSettings.atomstag = MPatomSettings.atomstag - 1;
        plot_atom();
        refresh_atom_parameters();
    end
elseif strcmp(check_string, 'atom_step_right')
    if MPatomSettings.atomstag == size(EEG.book.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,:,:),3) || any(EEG.book.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag+1,:)~=0) == 0
        disp 'No further atoms';
    else
        disp 'Displaying next atom'
        MPatomSettings.atomstag = MPatomSettings.atomstag + 1;
        plot_atom();
        refresh_atom_parameters();
    end
end
end

function plot_original()
    global EEG;
    global MPatomSettings;
    t  = EEG.book.epoch_labels(MPatomSettings.trialstag);
    ch = str2num(EEG.book.channel_labels{MPatomSettings.channelstag});
    plot(MPatomSettings.time , EEG.data(ch,:,t),'k','Parent',MPatomSettings.originalaxis);
    title(MPatomSettings.originalaxis,'Original signal');
    MPatomSettings.yaxlimits=get(MPatomSettings.originalaxis,'YLim');
    ylabel(MPatomSettings.originalaxis , 'Amplitude');
end
function plot_reconstruct()
    global MPatomSettings;
    global EEG;
    X = squeeze(EEG.book.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,:,:));
    plot(MPatomSettings.time , sum(real(X),1),'k','Parent',MPatomSettings.reconstructaxis);
    title(MPatomSettings.reconstructaxis,'Signal reconstruction');
    set(MPatomSettings.reconstructaxis,'YLim',MPatomSettings.yaxlimits);
    ylabel(MPatomSettings.reconstructaxis , 'Amplitude');
end
function plot_atom()
    global MPatomSettings;
    global EEG;
    plot(MPatomSettings.time , squeeze(real(EEG.book.reconstruction(MPatomSettings.trialstag,MPatomSettings.channelstag,MPatomSettings.atomstag,:))),'k','Parent',MPatomSettings.atomaxis);
    title(MPatomSettings.atomaxis,'Reconstructing functions');
    set(MPatomSettings.atomaxis,'YLim',MPatomSettings.yaxlimits);
    set(MPatomSettings.a(3),'String',num2str(MPatomSettings.atomstag));
    ylabel(MPatomSettings.atomaxis , 'Amplitude');
    xlabel(MPatomSettings.atomaxis , 'Time [s]');
end

function refresh_atom_parameters()
    global MPatomSettings;
    global EEG;
    % f(3)-pos f(5)-width f(7)-freq
    
    MPatomSettings.trialstag;
    MPatomSettings.channelstag;
    MPatomSettings.atomstag;
    ampl = abs(EEG.book.parameters(MPatomSettings.trialstag,MPatomSettings.channelstag).amplitudes(MPatomSettings.atomstag));
    env  = max(EEG.book.parameters(MPatomSettings.trialstag,MPatomSettings.channelstag).envelopes(MPatomSettings.atomstag,:));
    set(MPatomSettings.f(3),'String',num2str(ampl*env));
    width = find_width(EEG.book.parameters(MPatomSettings.trialstag,MPatomSettings.channelstag).envelopes(MPatomSettings.atomstag,:));
    set(MPatomSettings.f(5),'String',num2str(width));
    freq = EEG.book.parameters(MPatomSettings.trialstag,MPatomSettings.channelstag).frequencies(MPatomSettings.atomstag);
    set(MPatomSettings.f(7),'String',num2str(freq));
end

function width = find_width(signal)
    [mz mzi]=max(signal);
    
    id=find(signal(1:mzi)-0.5*mz<0);
    if isempty(id)
        L = mzi;
    else
        L = mzi-id(end);
    end

    id=find(signal(mzi:end)-0.5*mz<0);
    if isempty(id)
        R = size(signal,2);
    else
        R = id(1);
    end
    width = R - L;
end
