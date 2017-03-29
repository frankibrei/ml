function [nr_of_trials, mean_ifp_amps_MC,single_ifp_amps_MC]=b_get_ifpsMicMacMC(chan_list,samplerate,low_freq,high_freq,width_of_display_in_ms...
    ,xstart_offset_in_ms,filob,do_normalize,syncvek, first_sync,last_sync,subtract_mean,storage_type)
% b_get_ifpsMicMacMC: return also single sweeps
% ..MC für Multi Chan : mean over several chans
% .MicMac for MicMac data
do_notch_filter_50=true; %false; %true;
do_notch_filter_100=false; 
dataformat='int16';
filob.setLFPMicMac(true,low_freq,high_freq);

mean_ifp_amps_MC=zeros(width_of_display_in_ms,1);
nr_of_sweeps=last_sync-first_sync+1;
single_ifp_amps_MC=zeros(width_of_display_in_ms,nr_of_sweeps);


nr_of_channels=length(chan_list);

for ichan=1:nr_of_channels
    chan=chan_list(ichan);
    
    lfp_data1=filob.getMicMacChan(chan,samplerate,dataformat,storage_type);
    
    nr_of_samples=length(lfp_data1);
    
    %now notch filter needed !
    % Design a filter with a Q-factor of Q=35 to remove a 60 Hz tone from 
    % system running at 300 Hz.
    %Wo = 60/(300/2);  BW = Wo/35;
    if do_notch_filter_50
        Wo = 50/(1000/2);  BW = Wo/35; % remove 50 Hz, fs=1000 Hz
        [b,a] = iirnotch(Wo,BW);
        % lfp_data = filter(b,a,lfp_data1);
        lfp_data = filtfilt(b,a,lfp_data1);
        if do_notch_filter_100
            Wo = 100/(1000/2);  BW = Wo/35; % remove 50 Hz, fs=1000 Hz
            [b,a] = iirnotch(Wo,BW);
            lfp_data = filtfilt(b,a,lfp_data);
        end
    else
        lfp_data = lfp_data1;
    end
    
    
    nr_of_trials=0;
    
    mean_ifp_amps=zeros(width_of_display_in_ms,1);
    single_ifp_amps=zeros(width_of_display_in_ms,nr_of_sweeps);
    
    for isp=first_sync:last_sync
        tsync = syncvek(isp);
        % return part of data from tstart to tstop
        tstart=int32(tsync+xstart_offset_in_ms);
        if (tstart<1) tstart=1; end
        tstop=int32(tstart+width_of_display_in_ms-1);
        if (tstop>nr_of_samples) tstop=nr_of_samples; end
        lfp = lfp_data(tstart:tstop);
        if (length(lfp)<width_of_display_in_ms)
            lfp=[lfp;zeros(width_of_display_in_ms-length(lfp),1)];
        end
        if (do_normalize)
            lfp=normalize(lfp);
        else
            lfp=(lfp-mean(lfp));
            % lfp=abs(lfp-mean(lfp));
            % abs nur als Test, so die EKG-Wiederholungen bleiben
            % brachte aber keine Vergrößerung der sekundären Peaks
        end
        
        mean_ifp_amps(:)=mean_ifp_amps(:)+lfp;
        nr_of_trials=nr_of_trials+1;
        single_ifp_amps(:,nr_of_trials)=lfp;
    end
    if subtract_mean
        mean_ifp_amps=mean_ifp_amps/nr_of_trials;
    end
    mean_ifp_amps_MC=mean_ifp_amps_MC+mean_ifp_amps;
    single_ifp_amps_MC=single_ifp_amps_MC+single_ifp_amps;
end
mean_ifp_amps_MC=mean_ifp_amps_MC/nr_of_channels;
single_ifp_amps_MC=single_ifp_amps_MC/nr_of_channels;
end
