function [reconstructing_array] = mp_calc(EEG,channel_nr,epoch_nr,minS,maxS,dE,energy,iter,nfft)

if (channel_nr > EEG.nbchan) || (channel_nr < 1)
    throw(MException('MatchingPursuit:mp_calc','Nonexisting channel number.'));

elseif (epoch_nr > EEG.trials) || (epoch_nr < 1)
    throw(MException('MatchingPursuit:mp_calc','Nonexisting epoch number.'));
else
    dictionary_params = [minS maxS dE];
    disp 'Dictionary params - done';
    [book] = defineMixedInbook(dictionary_params , EEG.times);
    disp 'Dictionary - done';
    sig = EEG.data(channel_nr , : , epoch_nr)';
    disp 'Signal - done';
    out_book = mp6(sig , book , nfft , iter , energy , dE , 1 , EEG.srate);
    disp 'Parameters - done';
    
    
    reconstructing_array = zeros( size(out_book,2) , size(out_book(1).reconstruction,2));
    for i = 1: size(out_book,2)
        reconstructing_array(i,:) = out_book(1,i).reconstruction;
    end
    
    disp 'Reconstructing_array - done';
    
end


end