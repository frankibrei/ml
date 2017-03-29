function [syncvek_ms,rt_vek]=b_get_syncs_from_behav_flat(sweep_behav_vek,trial_struc2,icond,do_rt_sort,do_rt_sync)
sweep_inx=trial_struc2(icond).trial_list;
pres_start_ms=cell2mat({sweep_behav_vek.pres_start_ms});
reaction_time_ms=cell2mat({sweep_behav_vek.reaction_time_ms});
ston_vek_ms=pres_start_ms(sweep_inx);
rt_vek=reaction_time_ms(sweep_inx);
if do_rt_sync
    syncvek_ms=ston_vek_ms+rt_vek;
else
    syncvek_ms=ston_vek_ms;
end
if do_rt_sort
    [rtsort,inx]=sort(rt_vek);
    syncvek_ms=syncvek_ms(inx);
    rt_vek=rt_vek(inx);
end
end