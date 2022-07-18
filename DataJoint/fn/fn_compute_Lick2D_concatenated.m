function fn_compute_Lick2D_concatenated(key,self, rel_data, fr_interval)

smooth_window_sec=0.2; %frames for PSTH
timespent_min=5; %in trials

rel_ROI = (IMG.ROI-IMG.ROIBad) & key;

key_ROI1=fetch(rel_ROI,'ORDER BY roi_number'); %map

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
[~, ~, ~, x_idx, z_idx] = histcounts2(pos_x,pos_z,x_bins,z_bins);

% go_time=fetchn(EXP2.BehaviorTrialEvent & key & 'trial_event_type="go"','trial_event_time','LIMIT 1');
frame_rate = fetchn(IMG.FOVEpoch & key,'imaging_frame_rate');
smooth_window_frames = ceil(smooth_window_sec*frame_rate); %frames for PSTH

% TrialsStartFrame=fetchn(IMG.FrameStartTrial & key,'session_epoch_trial_start_frame','ORDER BY trial');
% if isempty(TrialsStartFrame) % not mesoscope recordings
%     TrialsStartFrame=fetchn(IMG.FrameStartFile & key,'session_epoch_file_start_frame', 'ORDER BY session_epoch_file_num');
% end

% L=fetch(EXP2.ActionEvent & key,'*');
R=fetch((EXP2.TrialRewardSize & key) - TRACKING.VideoGroomingTrial,'*','ORDER BY trial');

S=fetch(rel_data,'*');
if isfield(S,'spikes_trace') % to be able to run the code both on dff and on deconvulted "spikes" data
    [S.dff_trace] = S.spikes_trace;
    S = rmfield(S,'spikes_trace');
end

% num_trials = numel(TrialsStartFrame);
[start_file, end_file ] = fn_parse_into_trials (key,frame_rate, fr_interval);

num_trials =numel(start_file);

idx_response = (~isnan(start_file));
% idx odd/even
idx_odd = ismember(1:1:num_trials,1:2:num_trials) & idx_response;
idx_even =  ismember(1:1:num_trials,2:2:num_trials) & idx_response;

try
    % idx reward
    idx_small= strcmp({R.reward_size_type},'omission')  & idx_response;
    idx_regular = strcmp({R.reward_size_type},'regular') & idx_response;  % we don't include the first trial in the block
    idx_large= strcmp({R.reward_size_type},'large')   & idx_response;
catch
end


for i_x=1:1:numel(x_bins_centers)
    for i_z=1:1:numel(z_bins_centers)
        idx_xz {i_z,i_x} = find((x_idx==i_x)  & idx_response &  (z_idx==i_z));
    end
end

parfor i_roi=1:1:size(S,1)
    psth_all=[];
    psth_position_concat=  [];
    psth_position_concat_odd=  [];
    psth_position_concat_even=  [];
    psth_position_concat_regularreward=  [];
    psth_position_concat_regularreward_odd=  [];
    psth_position_concat_regularreward_even=  [];
    
    %% PSTH for each trial
    spikes=S(i_roi).dff_trace;
    for i_tr = 1:1:numel(start_file)
        if idx_response(i_tr)==0 %its an ignore trial
            psth_all{i_tr}=NaN;
            continue
        end
        s=spikes(start_file(i_tr):end_file(i_tr));
        s=movmean(s,[smooth_window_frames 0],'omitnan','Endpoints','shrink');
        time=(1:1:numel(s))/frame_rate + fr_interval(1);
        psth_all{i_tr}=s;
    end
    
    
    
    %% Contacatenated PSTH averaged per PSTH and contcatenated across all positions
    for i_x=1:1:numel(x_bins_centers)
        for i_z=1:1:numel(z_bins_centers)
            %             idx = find((x_idx==i_x)  & ~isnan(start_file) &  (z_idx==i_z));
            idx = idx_xz{i_z,i_x};
            
            
            if numel(idx)<timespent_min
                psth_position_concat=  [psth_position_concat (time+NaN)];
                psth_position_concat_odd= [psth_position_concat_odd (time+NaN)];
                psth_position_concat_even= [psth_position_concat_even (time+NaN)];
                psth_position_concat_regularreward= [psth_position_concat_regularreward (time+NaN)];
                psth_position_concat_regularreward_odd=  [psth_position_concat_regularreward_odd (time+NaN)];
                psth_position_concat_regularreward_even= [psth_position_concat_regularreward_even (time+NaN)];
            else
                psth_position_concat= [psth_position_concat double(mean(cell2mat([psth_all(idx)]'),1))];
                psth_position_concat_odd= [psth_position_concat_odd double(mean(cell2mat([psth_all(ismember([1:1:num_trials],idx) & idx_odd)]'),1))];
                psth_position_concat_even= [psth_position_concat_even double(mean(cell2mat([psth_all(ismember([1:1:num_trials],idx) & idx_even)]'),1))];
                
                try
                    psth_position_concat_regularreward= [psth_position_concat_regularreward double(mean(cell2mat([psth_all(idx)& idx_regular]'),1))];
                    psth_position_concat_regularreward_odd= [psth_position_concat_regularreward_odd double(mean(cell2mat([psth_all(ismember([1:1:num_trials],idx) & idx_odd & idx_regular)]'),1))];
                    psth_position_concat_regularreward_even= [psth_position_concat_regularreward_even double(mean(cell2mat([psth_all(ismember([1:1:num_trials],idx) & idx_even & idx_regular)]'),1))];
                catch
                    psth_position_concat_regularreward= [psth_position_concat_regularreward double(mean(cell2mat([psth_all(idx)]'),1))];
                    psth_position_concat_regularreward_odd= [psth_position_concat_regularreward_odd double(mean(cell2mat([psth_all(ismember([1:1:num_trials],idx) & idx_odd)]'),1))];
                    psth_position_concat_regularreward_even= [psth_position_concat_regularreward_even double(mean(cell2mat([psth_all(ismember([1:1:num_trials],idx) & idx_even)]'),1))];
                end
            end
            
            
        end
    end
    
    
    
    
    
    r=corr([psth_position_concat_odd(:),psth_position_concat_even(:)],'Rows' ,'pairwise');
    psth_position_concat_odd_even_corr=r(2);
    
    r=corr([psth_position_concat_regularreward_odd(:),psth_position_concat_regularreward_even(:)],'Rows' ,'pairwise');
    psth_position_concat_regularreward_odd_even_corr=r(2);
    
    
    key_ROI1(i_roi).session_epoch_type = key.session_epoch_type;
    key_ROI1(i_roi).session_epoch_number = key.session_epoch_number;
    key_ROI1(i_roi).number_of_bins = key.number_of_bins;
    
    
    key_ROI1(i_roi).psth_position_concat = psth_position_concat;
    %     key_ROI1(i_roi).psth_position_concat_odd = psth_position_concat_odd;
    %     key_ROI1(i_roi).psth_position_concat_even = psth_position_concat_even;
    key_ROI1(i_roi).psth_position_concat_odd_even_corr = psth_position_concat_odd_even_corr;
    
    key_ROI1(i_roi).psth_position_concat_regularreward = psth_position_concat_regularreward;
    %     key_ROI1(i_roi).psth_position_concat_regularreward_odd = psth_position_concat_regularreward_odd;
    %     key_ROI1(i_roi).psth_position_concat_regularreward_even = psth_position_concat_regularreward_even;
    key_ROI1(i_roi).psth_position_concat_regularreward_odd_even_corr = psth_position_concat_regularreward_odd_even_corr;
    
    
    key_ROI1(i_roi).psthmap_time = time;
    key_ROI1(i_roi).pos_x_bins_centers = x_bins_centers;
    key_ROI1(i_roi).pos_z_bins_centers = z_bins_centers;
    
    
    
%     k1=key_ROI1(i_roi);
%     insert(self, k1);
end
    insert(self, key_ROI1);
