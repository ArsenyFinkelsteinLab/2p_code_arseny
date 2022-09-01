function fn_compute_Lick2D_map_and_selectivity3(key,self, rel_data, fr_interval)

smooth_window_sec=0.2; %frames for PSTH
timespent_min=5; %in trials
timespent_min_partial=2; %in trials, for partial conditions (e.g. reward modulation, and trial number in block )
%Smoothing parameters for 2D maps
sigma=1;
hsize=1;

rel_ROI = (IMG.ROI-IMG.ROIBad) & key;

key_ROI1=fetch(rel_ROI,'ORDER BY roi_number'); %2D map
key_ROI2=fetch(rel_ROI,'ORDER BY roi_number'); %2D map PSTH
key_ROI3=fetch(rel_ROI,'ORDER BY roi_number'); %2D map stats
key_ROI4=fetch(rel_ROI,'ORDER BY roi_number'); %psth selectivity (preferred-nonpreferred computed based on the 2D map)
key_ROI5=fetch(rel_ROI,'ORDER BY roi_number'); %psth selectivity stats

rel_data =rel_data & rel_ROI & key;

        [data_SessionTrial] = fn_EmptyStruct ('LICK2D.ROILick2DmapSpikes');



%% Rescaling, rotation, and binning
[POS, number_of_bins] = fn_rescale_and_rotate_lickport_pos (key);
key.number_of_bins=number_of_bins;
pos_x = POS.pos_x;
pos_z = POS.pos_z;

x_bins = linspace(-1, 1,key.number_of_bins+1);
P.x_bins_centers=x_bins(1:end-1)+mean(diff(x_bins))/2;

z_bins = linspace(-1,1,key.number_of_bins+1);
P.z_bins_centers=z_bins(1:end-1)+mean(diff(z_bins))/2;

x_bins(1)= -inf;
x_bins(end)= inf;
z_bins(1)= -inf;
z_bins(end)= inf;



%% Compute maps
[hhhhh, ~, ~, P.x_idx, P.z_idx] = histcounts2(pos_x,pos_z,x_bins,z_bins);

%plot(pos_x,pos_z,'.')


mat_x=repmat(P.x_bins_centers,key.number_of_bins,1);
mat_z=repmat(P.z_bins_centers',1,key.number_of_bins);


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
    self2=LICK2D.ROILick2DmapPSTHSpikes;
    self3=LICK2D.ROILick2DmapStatsSpikes;
    self4=LICK2D.ROILick2DSelectivitySpikes;
    self5=LICK2D.ROILick2DSelectivityStatsSpikes;
else
    self2=LICK2D.ROILick2DmapPSTH;
    self3=LICK2D.ROILick2DmapStats;
    self4=LICK2D.ROILick2DSelectivity;
    self5=LICK2D.ROILick2DSelectivityStats;
end

% num_trials = numel(TrialsStartFrame);
[start_file, end_file ] = fn_parse_into_trials (key,frame_rate, fr_interval);

P.num_trials =numel(start_file);

P.idx_response = (~isnan(start_file));


try
    
    % idx reward
    P.idx_regular = strcmp({R.reward_size_type},'regular')  & P.idx_response;
    P.idx_small= strcmp({R.reward_size_type},'omission')  & P.idx_response;
    P.idx_large= strcmp({R.reward_size_type},'large')  & P.idx_response;
    
    % idx order in a block
    P.num_trials_in_block=mode([Block.num_trials_in_block]); %the most frequently occurring number of trials per block (in case num trials in block change within session)
    begin_mid_end_bins = linspace(2,P.num_trials_in_block,4);
    P.idx_first = [Block.current_trial_num_in_block]==1 & P.idx_response & P.idx_regular;
    P.idx_begin = ([Block.current_trial_num_in_block]>=begin_mid_end_bins(1) & [Block.current_trial_num_in_block]<=floor(begin_mid_end_bins(2)) ) & P.idx_response & P.idx_regular;
    P.idx_mid=   ([Block.current_trial_num_in_block]>begin_mid_end_bins(2) & [Block.current_trial_num_in_block]<=round(begin_mid_end_bins(3)) ) & P.idx_response & P.idx_regular;
    P.idx_end=   ([Block.current_trial_num_in_block]>begin_mid_end_bins(3) & [Block.current_trial_num_in_block]<=ceil(begin_mid_end_bins(4)) ) & idx_response & idx_regular;
    
    P.idx_odd_regular = find(P.idx_regular);
    P.idx_odd_regular = P.idx_odd_regular(1:2:sum(P.idx_regular));
    P.idx_odd_regular = ismember(1:1:P.num_trials,P.idx_odd_regular);
    P.idx_even_regular = find(P.idx_regular);
    P.idx_even_regular = P.idx_even_regular(2:2:sum(P.idx_regular));
    P.idx_even_regular = ismember(1:1:P.num_trials,P.idx_even_regular);
    
catch
    P.idx_regular = 1:1:P.num_trials  & P.idx_response;
    P.idx_odd_regular = ismember(1:1:P.num_trials,1:2:P.num_trials) & P.idx_response;
    P.idx_even_regular =  ismember(1:1:P.num_trials,2:2:P.num_trials) & P.idx_response;
end


for i_x=1:1:numel(P.x_bins_centers)
    for i_z=1:1:numel(P.z_bins_centers)
        P.idx_xz {i_z,i_x} = find((P.x_idx==i_x)  & P.idx_response &  (P.z_idx==i_z));
    end
end

for i_roi=1:1:size(S,1)

 fn_2d_map_per_roi(i_roi,P,key) 
 
end

%bulk insertion
insert(self, key_ROI1);
insert(self2, key_ROI2);
insert(self3, key_ROI3);
insert(self4, key_ROI4);
insert(self5, key_ROI5);