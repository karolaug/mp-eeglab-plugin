% pop_mp_calc() - Returns parameterised signal and plots time-frequency map
% of it.
%
% Usage:
%   >> pop_mp_calc(EEG);          % pop_up window
%   >> mp_calc(EEG,channel_nr,epoch_nr,minS,maxS,dE,energy,iter,nfft);

function EEG = pop_mp_calc(EEG)

title_string = 'Parameterise a signal in time-frequency domain by means of MP procedure -- pop_mp_calc()';
geometry = { 1 [1 1] [1 1] 1 1 [1 1] [1 1] [1 1] 1 1 [1 1] [1 1] [1 1] };
uilist = { ...
         { 'style', 'text', 'string', 'Data info: ', 'fontweight', 'bold'}, ...
         { 'style', 'text', 'string', 'Channel numbers: ' }, ...
         { 'style', 'edit', 'string', '1', 'tag', 'channel_nr'}, ...
         { 'style', 'text', 'string', 'Epoch numbers: ' }, ...
         { 'style', 'edit', 'string', '1', 'tag', 'epoch_nr'}, ...
         { }, ...
         { 'style', 'text', 'string', 'Dictionary info: ', 'fontweight', 'bold'}, ...
         { 'style', 'text', 'string', 'minS: ' }, ...
         { 'style', 'edit', 'string', '16', 'tag', 'minS'}, ...
         { 'style', 'text', 'string', 'maxS: ' }, ...
         { 'style', 'edit', 'string', '512', 'tag', 'maxS'}, ...
         { 'style', 'text', 'string', 'dE: ' }, ...
         { 'style', 'edit', 'string', '0.05', 'tag', 'dE'}, ...
         { }, ...
         { 'style', 'text', 'string', 'Decomposition parameters: ', 'fontweight', 'bold'}, ...
         { 'style', 'text', 'string', 'Energy percentage: ' }, ...
         { 'style', 'edit', 'string', '0.95', 'tag', 'energy'}, ...
         { 'style', 'text', 'string', 'Maximal number of iterations: ' }, ...
         { 'style', 'edit', 'string', '15', 'tag', 'iter'}, ...
         { 'style', 'text', 'string', 'min_NFFT: ' }, ...
         { 'style', 'edit', 'string', '1024', 'tag', 'nfft'}};

[~, ~, err params] = inputgui( 'geometry', geometry, 'uilist', uilist, 'helpcom', 'pophelp(''pop_mp_calc'');', 'title' , title_string);



try
    params.channel_nr = str2num(params.channel_nr);
    params.epoch_nr   = str2num(params.epoch_nr);
    params.dE         = str2num(params.dE);
    params.minS       = str2num(params.minS);
    params.maxS       = str2num(params.maxS);
    params.iter       = str2num(params.iter);
    params.nfft       = str2num(params.nfft);
    params.energy     = str2num(params.energy);
    
    try
        EEG = rmfield(EEG , 'book');
    catch
        
    end
    
    EEG.book.reconstruction = zeros(size(params.epoch_nr,2),size(params.channel_nr,2),params.iter,size(EEG.data,2));
    for ch = 1:1:size(params.channel_nr,2)
        for ep = 1:1:size(params.epoch_nr,2)
            sprintf('Calculations for channel: %u, epoch: %u.',ch,ep)
            [X , Y] = mp_calc(EEG,params.channel_nr(ch),params.epoch_nr(ep),params.minS,params.maxS,params.dE,params.energy,params.iter,params.nfft);
            EEG.book.reconstruction(ep,ch,1:size(X,1),:) = X;
            EEG.book.parameters(ep,ch) = Y;
        end
    end
    
    EEG.book.epoch_labels = params.epoch_nr;
    
    if ~isempty(EEG.chanlocs)
        for i = 1:size(params.channel_nr,2)
            EEG.book.channel_labels{i} = EEG.chanlocs(1,params.channel_nr(i)).labels;
        end
    else
        for i = 1:size(params.channel_nr,2)
            EEG.book.channel_labels{i} = num2str(params.channel_nr(i));
        end
    end
    disp 'Done'
    
catch
    disp 'Aborted by user'
end

end


 