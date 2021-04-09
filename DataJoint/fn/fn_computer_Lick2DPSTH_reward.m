function fn_computer_Lick2DPSTH_reward(key,self)

time_bin=[-3,3]; %2 sec for PSTH, aligned to lick
fr_interval1=[key.fr_interval_start1,key.fr_interval_end1]/1000;
fr_interval2=[key.fr_interval_start2,key.fr_interval_end2]/1000;

smooth_window=1; %frames for PSTH

key_ROI=fetch((IMG.ROI-IMG.ROIBad)&key,'ORDER BY roi_number');

LickPort=fetch(EXP2.TrialLickPort & key,'*');

go_time=fetchn(EXP2.BehaviorTrialEvent & key & 'trial_event_type="go"','trial_event_time','LIMIT 1');
frame_rate = fetchn(IMG.FOVEpoch & key,'imaging_frame_rate');

Files=fetch(IMG.FrameStartFile & key,'*','ORDER BY session_epoch_file_num');
L=fetch(EXP2.ActionEvent & key,'*','ORDER BY trial');

S=fetch(IMG.ROISpikes & key,'*','ORDER BY roi_number');


for i_tr = 1:1:size(LickPort,1)
    licks=[L(find([L.trial]==i_tr)).action_event_time];
    licks=licks(licks>go_time);
    if ~isempty(licks)
        start_file(i_tr)=Files(i_tr).session_epoch_file_start_frame + floor(licks(1)*frame_rate) + floor(time_bin(1)*frame_rate);
        end_file(i_tr)=start_file(i_tr)+ceil([time_bin(2)-time_bin(1)]*frame_rate);
        if start_file(i_tr)<=0
            start_file(i_tr)=NaN;
            end_file(i_tr)=NaN;
        end
    else
        start_file(i_tr)=NaN;
        end_file(i_tr)=NaN;
    end
end


R=fetch(EXP2.TrialRewardSize & key,'*','ORDER BY trial');
Block=fetch(EXP2.TrialLickBlock & key,'*','ORDER BY trial');

for i_roi=1:1:size(S,1)
    
    spikes=S(i_roi).spikes_trace;
    for i_tr = 1:1:size(LickPort,1)
        if isnan(start_file(i_tr))
            fr_all(i_roi,i_tr)=NaN;
            psth_all{i_roi,i_tr}=NaN;
            continue
        end
        s=spikes(start_file(i_tr):end_file(i_tr));
        s=movmean(s,[smooth_window 0],'omitnan','Endpoints','shrink');
        time=(1:1:numel(s))/frame_rate + time_bin(1);
        psth_all{i_roi,i_tr}=s;
    end

    idx_regular = find( ~isnan(start_file)  & strcmp({R.reward_size_type},'regular')  & ([Block.current_trial_num_in_block]~=1)); % we don't include the first trial in the block
    idx_large= find( ~isnan(start_file)  & strcmp({R.reward_size_type},'large')  & ([Block.current_trial_num_in_block]~=1));
    idx_small= find( ~isnan(start_file)  & strcmp({R.reward_size_type},'omission')  & ([Block.current_trial_num_in_block]~=1));
    
    %     psth=cell2mat(psth_all(i_roi, idx_regular)');
    psth_averaged_over_all_positions_regular = mean(cell2mat(psth_all(i_roi, idx_regular)'),1);
    psth_averaged_over_all_positions_large = mean(cell2mat(psth_all(i_roi, idx_large)'),1);
    psth_averaged_over_all_positions_small = mean(cell2mat(psth_all(i_roi, idx_small)'),1);
    
    %     psth_stem_over_all_positions_regular = std(psth,1)/sqrt(sum(idx));
    %
    %     psth_interval1=psth(:,time>fr_interval1(1) & time<=fr_interval1(2));
    %         psth_interval2=psth(:,time>fr_interval2(1) & time<=fr_interval2(2));
    
    %        pval_psth = ranksum(mean(psth_interval1,2),mean(psth_interval2,2));
    
    
    
    %     [~, p_val] = ttest(mean(Fbase,2),mean(Fstim,2));
    
    
    
    
    key_ROI(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI(i_roi).fr_interval_start1 =key.fr_interval_start1;
    key_ROI(i_roi).fr_interval_end1 =key.fr_interval_end1;
    key_ROI(i_roi).fr_interval_start2 =key.fr_interval_start2;
    key_ROI(i_roi).fr_interval_end2 =key.fr_interval_end2;
    
    
    key_ROI(i_roi).psth_averaged_over_all_positions_regular = psth_averaged_over_all_positions_regular;
    %     key_ROI(i_roi).psth_stem_over_all_positions_regular = psth_stem_over_all_positions_regular;
    %       key_ROI(i_roi).pval_psth = pval_psth;
    
    key_ROI(i_roi).psth_averaged_over_all_positions_large = psth_averaged_over_all_positions_large;
    key_ROI(i_roi).psth_averaged_over_all_positions_small = psth_averaged_over_all_positions_small;
    
    
    k2=key_ROI(i_roi);
    insert(self, k2);
end