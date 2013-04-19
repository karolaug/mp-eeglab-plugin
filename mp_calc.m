function [out_book] = mp_calc(EEG,channel_nr,epoch_nr,minS,maxS,dE,energy,iter,nfft)

  if (channel_nr > EEG.nbchan) || (channel_nr < 1)
  throw(MException('MatchingPursuit:mp_calc','Nonexisting channel or epoch number.'));

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
    disp 'Book - done';
end


end
