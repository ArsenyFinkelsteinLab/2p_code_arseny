function fn_compute_Lick2D_map_and_selectivity(key,self, rel_data, fr_interval)

smooth_window_sec=0.2; %frames for PSTH
timespent_min=5; %in trials

sigma=1;
hsize=1;

rel_ROI = (IMG.ROI-IMG.ROIBad) & key;

key_ROI1=fetch(rel_ROI,'ORDER BY roi_number'); %map
key_ROI2=fetch(rel_ROI,'ORDER BY roi_number'); %psth_preferred_odd_even_corrselectivity
key_ROI3=fetch(rel_ROI,'ORDER BY roi_number'); %selectivity stats

rel_data =rel_data & rel_ROI & key;


%% Rescaling, rotation, and binning
[POS, number_of_bins] = fn_rescale_and_rotate_lickport_pos (key);
key.number_of_bins=number_of_bins;
pos_x = POS.pos_x;
pos_z = POS.pos_z;

x_bins = linspace(-1, 1,key.number_of_bins+1);
x_bins_centers=x_bins(1:end-1)+mean(diff(x_bins))/2;

z_bins = linspace(-1,1,key.number_of_bins+1);
z_bins_centers=z_bins(1:end-1)+mean(diff(z_bins))/2;

x_bins(1)= -inf;
x_bins(end)= inf;
z_bins(1)= -inf;
z_bins(end)= inf;



%% Compute maps
[hhhhh, ~, ~, x_idx, z_idx] = histcounts2(pos_x,pos_z,x_bins,z_bins);

%plot(pos_x,pos_z,'.')


mat_x=repmat(x_bins_centers,key.number_of_bins,1);
mat_z=repmat(z_bins_centers',1,key.number_of_bins);


% go_time=fetchn(EXP2.BehaviorTrialEvent & key & 'trial_event_type="go"','trial_event_time','LIMIT 1');
frame_rate = fetchn(IMG.FOVEpoch & key,'imaging_frame_rate');
smooth_window_frames = ceil(smooth_window_sec*frame_rate); %frames for PSTH

% TrialsStartFrame=fetchn(IMG.FrameStartTrial & key,'session_epoch_trial_start_frame','ORDER BY trial');
% if isempty(TrialsStartFrame) % not mesoscope recordings
%     TrialsStartFrame=fetchn(IMG.FrameStartFile & key,'session_epoch_file_start_frame', 'ORDER BY session_epoch_file_num');
% end

% L=fetch(EXP2.ActionEvent & key,'*');
R=fetch((EXP2.TrialRewardSize & key) - TRACKING.VideoGroomingTrial,'*','ORDER BY trial');
Block=fetch((EXP2.TrialLickBlock & key) - TRACKING.VideoGroomingTrial,'*','ORDER BY trial');

S=fetch(rel_data,'*');
if isfield(S,'spikes_trace') % to be able to run the code both on dff and on deconvulted "spikes" data
    [S.dff_trace] = S.spikes_trace;
    S = rmfield(S,'spikes_trace');
    self2=LICK2D.ROILick2DSelectivitySpikes;
    self3=LICK2D.ROILick2DSelectivityStatsSpikes;
else
    self2=LICK2D.ROILick2DSelectivity;
    self3=LICK2D.ROILick2DSelectivityStats;
end

% num_trials = numel(TrialsStartFrame);
[start_file, end_file ] = fn_parse_into_trials (key,frame_rate, fr_interval);

num_trials =numel(start_file);

idx_response = (~isnan(start_file));
% idx odd/even
idx_odd = ismember(1:1:num_trials,1:2:num_trials) & idx_response;
idx_even =  ismember(1:1:num_trials,2:2:num_trials) & idx_response;

try
    % idx order in a block
    idx_first = [Block.current_trial_num_in_block]==1 & idx_response;
    idx_begin = ([Block.current_trial_num_in_block]==2 | [Block.current_trial_num_in_block]==3) & idx_response;
    idx_mid=   ([Block.current_trial_num_in_block]==4 | [Block.current_trial_num_in_block]==5) & idx_response;
    idx_end=    ([Block.current_trial_num_in_block]==6 | [Block.current_trial_num_in_block]==7) & idx_response;
    
    % idx reward
    idx_small= strcmp({R.reward_size_type},'omission')  & [Block.current_trial_num_in_block]~=1 & idx_response;
    idx_regular = strcmp({R.reward_size_type},'regular')  & [Block.current_trial_num_in_block]~=1 & idx_response;  % we don't include the first trial in the block
    idx_large= strcmp({R.reward_size_type},'large')  & [Block.current_trial_num_in_block]~=1 & idx_response;
catch
end


for i_x=1:1:numel(x_bins_centers)
    for i_z=1:1:numel(z_bins_centers)
        idx_xz {i_z,i_x} = find((x_idx==i_x)  & idx_response &  (z_idx==i_z));
    end
end

for i_roi=1:1:size(S,1)
    
    %% PSTH
    spikes=S(i_roi).dff_trace;
    for i_tr = 1:1:numel(start_file)
        if idx_response(i_tr)==0 %its an ignore trial
            fr_all(i_roi,i_tr)=NaN;
            psth_all{i_roi,i_tr}=NaN;
            continue
        end
        s=spikes(start_file(i_tr):end_file(i_tr));
        s=movmean(s,[smooth_window_frames 0],'omitnan','Endpoints','shrink');
        time=(1:1:numel(s))/frame_rate + fr_interval(1);
        s_interval=s(time>fr_interval(1) & time<=fr_interval(2));
        fr_all(i_roi,i_tr)= sum(s_interval)/numel(s_interval); %taking mean fr
        %         fr_all(i_roi,i_tr)= max(s_interval); %taking the max
        psth_all{i_roi,i_tr}=s;
    end
    
    
    
    %% 2D maps
    for i_x=1:1:numel(x_bins_centers)
        for i_z=1:1:numel(z_bins_centers)
            %             idx = find((x_idx==i_x)  & ~isnan(start_file) &  (z_idx==i_z));
            idx = idx_xz{i_z,i_x};
            
            map_xz_spikes_binned(i_z,i_x) = sum(fr_all(i_roi,idx));
            map_xz_spikes_binned_odd(i_z,i_x) = sum(fr_all(i_roi,  ismember([1:1:num_trials],idx) & idx_odd   ));
            map_xz_spikes_binned_even(i_z,i_x) = sum(fr_all(i_roi,  ismember([1:1:num_trials],idx) & idx_even   ));
            
            map_xz_timespent_binned(i_z,i_x) = numel(idx);
            map_xz_timespent_binned_odd(i_z,i_x) = sum( ismember([1:1:num_trials],idx) & idx_odd);
            map_xz_timespent_binned_even(i_z,i_x) = sum( ismember([1:1:num_trials],idx) & idx_even);
            
            if numel(idx)<timespent_min
                psth_per_position{i_z,i_x}=  time+NaN;
                psth_per_position_odd{i_z,i_x}= time+NaN;
                psth_per_position_even{i_z,i_x}= time+NaN;
            else
                psth_per_position{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi,idx)]'),1));
                psth_per_position_odd{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi,ismember([1:1:num_trials],idx) & idx_odd)]'),1));
                psth_per_position_even{i_z,i_x}= double(mean(cell2mat([psth_all(i_roi,ismember([1:1:num_trials],idx) & idx_even)]'),1));
            end
            
            
        end
    end
    
    % to avoid negative "firing rates"
    if min(map_xz_spikes_binned(:))<0
        map_xz_spikes_binned = map_xz_spikes_binned - min(map_xz_spikes_binned(:));
    end
    if min(map_xz_spikes_binned_odd(:))<0
        map_xz_spikes_binned_odd = map_xz_spikes_binned_odd - min(map_xz_spikes_binned_odd(:));
    end
    if min(map_xz_spikes_binned_even(:))<0
        map_xz_spikes_binned_even = map_xz_spikes_binned_even - min(map_xz_spikes_binned_even(:));
    end
    
    [~, lickmap_fr, ~, information_per_spike, ~, ~, ~, ~] ...
        = fn_compute_generic_2D_field2 ...
        (x_bins, z_bins, map_xz_timespent_binned, map_xz_spikes_binned, timespent_min, sigma, hsize, 0);
    
    [~, lickmap_fr_odd, ~, ~, ~, ~, ~, ~] ...
        = fn_compute_generic_2D_field2 ...
        (x_bins, z_bins, map_xz_timespent_binned_odd, map_xz_spikes_binned_odd, timespent_min, sigma, hsize, 0);
    
    [~, lickmap_fr_even, ~, ~, ~, ~, ~, ~] ...
        = fn_compute_generic_2D_field2 ...
        (x_bins, z_bins, map_xz_timespent_binned_even, map_xz_spikes_binned_even, timespent_min, sigma, hsize, 0);
    
    
    
    r_odd_even=corr([lickmap_fr_odd(:),lickmap_fr_even(:)],'Rows' ,'pairwise');
    r_odd_even=r_odd_even(2);
    
    [~,preferred_bin_idx]=nanmax(lickmap_fr(:));
    preferred_radius = sqrt(mat_x(preferred_bin_idx)^2 + mat_z(preferred_bin_idx)^2) ;
    
    % preferred idx
    [~,I_max]=sort(lickmap_fr(:));
    if key.number_of_bins>3
        idx_preferred = ismember(1:1:num_trials,[idx_xz{I_max(end-1:end)}]); % we take 2 highest bin
    else
        idx_preferred = ismember(1:1:num_trials,[idx_xz{I_max(end)}]); % we take 1 highest bin
    end
    % non preferred idx
    idx_non_preferred = logical(1:1:num_trials);
    idx_non_preferred (idx_preferred | ~idx_response )=0;
    
    
    %% MAP
    
    key_ROI1(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI1(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI1(i_roi).number_of_bins = key.number_of_bins;

    
    
    key_ROI1(i_roi).psth_per_position = psth_per_position;
    key_ROI1(i_roi).psth_per_position_odd = psth_per_position_odd;
    key_ROI1(i_roi).psth_per_position_even = psth_per_position_even;
    key_ROI1(i_roi).psthmap_time = time;
    key_ROI1(i_roi).lickmap_fr = lickmap_fr;
    key_ROI1(i_roi).lickmap_fr_odd = lickmap_fr_odd;
    key_ROI1(i_roi).lickmap_fr_even = lickmap_fr_even;
    key_ROI1(i_roi).lickmap_odd_even_corr = r_odd_even;
    key_ROI1(i_roi).pos_x_bins_centers = x_bins_centers;
    key_ROI1(i_roi).pos_z_bins_centers = z_bins_centers;
    key_ROI1(i_roi).information_per_spike = information_per_spike;
    key_ROI1(i_roi).preferred_bin = preferred_bin_idx;
    key_ROI1(i_roi).preferred_radius = preferred_radius;
    
    
    %% Selectivity
    key_ROI2(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI2(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI2(i_roi).number_of_bins = key.number_of_bins;

    
    key_ROI3(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI3(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI3(i_roi).number_of_bins = key.number_of_bins;

    
    
    %     peaktime_selectivity               : double   # peak time of the psth
    % peaktime_selectivity_odd           : double   #
    % peaktime_selectivity_even          : double   #
    % peaktime_selectivity_first=null          : double   # first trial in block
    % peaktime_selectivity_begin=null    : double   #  trials in the beginning of the block
    % peaktime_selectivity_mid=null      : double   # trials in the middle of the block
    % peaktime_selectivity_end=null      : double   # trials in the end of the block
    % peaktime_selectivity_small=null    : double   # during no rewarded trials
    % peaktime_selectivity_regular=null  : double   # during trials with typical reward
    % peaktime_selectivity_large=null    : double   # during trials with large reward
    
    
    
    %preferred bins
    psth_preferred =  nanmean(cell2mat(psth_all(i_roi, idx_preferred)'),1);
    psth_preferred_odd =  nanmean(cell2mat(psth_all(i_roi, idx_preferred & idx_odd)'),1);
    psth_preferred_even = nanmean(cell2mat(psth_all(i_roi,idx_preferred  & idx_even)'),1);
    
    key_ROI2(i_roi).psth_preferred =  psth_preferred;
    key_ROI2(i_roi).psth_preferred_odd =  psth_preferred_odd;
    key_ROI2(i_roi).psth_preferred_even =  psth_preferred_even;
    
    
    r = corr([psth_preferred_odd(:),psth_preferred_even(:)+eps],'Rows' ,'pairwise');
    key_ROI3(i_roi).psth_preferred_odd_even_corr = r(2);
    [~,idx_peak]=max(psth_preferred);
    key_ROI3(i_roi).peaktime_preferred = time(idx_peak);
    [~,idx_peak]=max(psth_preferred_odd);
    key_ROI3(i_roi).peaktime_preferred_odd = time(idx_peak);
    [~,idx_peak]=max(psth_preferred_even);
    key_ROI3(i_roi).peaktime_preferred_even = time(idx_peak);
    
    
    %non preferred bins
    psth_non_preferred =  nanmean(cell2mat(psth_all(i_roi, idx_non_preferred)'),1);
    psth_non_preferred_odd =  nanmean(cell2mat(psth_all(i_roi, idx_non_preferred & idx_odd)'),1);
    psth_non_preferred_even = nanmean(cell2mat(psth_all(i_roi,idx_non_preferred  & idx_even)'),1);
    
    key_ROI2(i_roi).psth_non_preferred = psth_non_preferred;
    
    
    % selectivity
    selectivity =psth_preferred - psth_non_preferred;
    selectivity_odd = psth_preferred_odd - psth_non_preferred_odd;
    selectivity_even = psth_preferred_even - psth_non_preferred_even;
    
    key_ROI2(i_roi).selectivity = selectivity;
    key_ROI2(i_roi).selectivity_odd = selectivity_odd;
    key_ROI2(i_roi).selectivity_even = selectivity_even;
    
    r = corr([selectivity_odd(:),selectivity_even(:)],'Rows' ,'pairwise');
    key_ROI3(i_roi).selectivity_odd_even_corr= r(2);
    
    r = corr([selectivity_odd(:),selectivity_even(:)],'Rows' ,'pairwise');
    key_ROI3(i_roi).selectivity_odd_even_corr = r(2);
    [~,idx_peak]=max(selectivity);
    key_ROI3(i_roi).peaktime_selectivity = time(idx_peak);
    [~,idx_peak]=max(selectivity_odd);
    key_ROI3(i_roi).peaktime_selectivity_odd = time(idx_peak);
    [~,idx_peak]=max(selectivity_even);
    key_ROI3(i_roi).peaktime_selectivity_even = time(idx_peak);
    
    try
        % selectivity blocks
        if sum(idx_preferred & idx_small)>timespent_min
            selectivity_first = nanmean(cell2mat(psth_all(i_roi,idx_preferred & idx_first)'),1) -  nanmean(cell2mat(psth_all(i_roi,idx_non_preferred & idx_first)'),1);
        else
            selectivity_first=time + NaN;
        end
        
        if sum(idx_preferred & idx_regular)>timespent_min
            selectivity_begin = nanmean(cell2mat(psth_all(i_roi,idx_preferred & idx_begin)'),1) -  nanmean(cell2mat(psth_all(i_roi,idx_non_preferred & idx_begin)'),1);
        else
            selectivity_begin=time + NaN;
        end
        
        if sum(idx_preferred & idx_regular)>timespent_min
            selectivity_mid = nanmean(cell2mat(psth_all(i_roi,idx_preferred & idx_mid)'),1) -  nanmean(cell2mat(psth_all(i_roi,idx_non_preferred & idx_mid)'),1);
        else
            selectivity_mid=time + NaN;
        end
        
        if sum(idx_preferred & idx_regular)>timespent_min
            selectivity_end = nanmean(cell2mat(psth_all(i_roi,idx_preferred & idx_end)'),1) -  nanmean(cell2mat(psth_all(i_roi,idx_non_preferred & idx_end)'),1);
        else
            selectivity_end=time + NaN;
        end
        
        
        %selectivity reward
        if sum(idx_preferred & idx_small)>timespent_min
            selectivity_small =nanmean(cell2mat(psth_all(i_roi,idx_preferred & idx_small)'),1) -  nanmean(cell2mat(psth_all(i_roi,idx_non_preferred & idx_small)'),1);
        else
            selectivity_small=time + NaN;
        end
        if sum(idx_preferred & idx_regular)>timespent_min
            selectivity_regular =nanmean(cell2mat(psth_all(i_roi,idx_preferred & idx_regular)'),1) -  nanmean(cell2mat(psth_all(i_roi,idx_non_preferred & idx_regular)'),1);
        else
            selectivity_regular=time + NaN;
        end
        if sum(idx_preferred & idx_large)>timespent_min
            selectivity_large =nanmean(cell2mat(psth_all(i_roi,idx_preferred & idx_large)'),1) -  nanmean(cell2mat(psth_all(i_roi,idx_non_preferred & idx_large)'),1);
        else
            selectivity_large=time + NaN;
        end
        
        key_ROI2(i_roi).selectivity_first = selectivity_first;
        key_ROI2(i_roi).selectivity_begin = selectivity_begin;
        key_ROI2(i_roi).selectivity_mid = selectivity_mid;
        key_ROI2(i_roi).selectivity_end = selectivity_end;
        
        key_ROI2(i_roi).selectivity_small = selectivity_small;
        key_ROI2(i_roi).selectivity_regular = selectivity_regular;
        key_ROI2(i_roi).selectivity_large = selectivity_large;
        
        [~,idx_peak]=max(selectivity_first);
        key_ROI3(i_roi).peaktime_selectivity_first = time(idx_peak);
        [~,idx_peak]=max(selectivity_begin);
        key_ROI3(i_roi).peaktime_selectivity_begin = time(idx_peak);
        [~,idx_peak]=max(selectivity_mid);
        key_ROI3(i_roi).peaktime_selectivity_mid = time(idx_peak);
        [~,idx_peak]=max(selectivity_end);
        key_ROI3(i_roi).peaktime_selectivity_end = time(idx_peak);
        
        [~,idx_peak]=max(selectivity_small);
        key_ROI3(i_roi).peaktime_selectivity_small = time(idx_peak);
        [~,idx_peak]=max(selectivity_regular);
        key_ROI3(i_roi).peaktime_selectivity_regular = time(idx_peak);
        [~,idx_peak]=max(selectivity_large);
        key_ROI3(i_roi).peaktime_selectivity_large = time(idx_peak);
        
    catch
    end
    
    
    

    
    key_ROI2(i_roi).selectivity_time = time;
    
    k1=key_ROI1(i_roi);
    insert(self, k1);
    
    k2=key_ROI2(i_roi);
    insert(self2, k2);
    
    k3=key_ROI3(i_roi);
    insert(self3, k3);
end