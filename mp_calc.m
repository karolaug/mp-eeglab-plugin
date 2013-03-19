function [out_book] = mp_calc(EEG,channel_nr,epoch_nr,minS,maxS,dE,energy,iter,nfft)

if (channel_nr > EEG.nbchan) || (epoch_nr > EEG.trials)
    disp 'dupa';
else
    dictionary_params = [minS maxS dE];
    [book] = defineMixedInbook(dictionary_params , EEG.times);
    sig = EEG.data(channel_nr , : , epoch_nr)';
    out_book = mp6(sig , book , nfft , iter , energy , dE , 1 , EEG.srate);
end


end