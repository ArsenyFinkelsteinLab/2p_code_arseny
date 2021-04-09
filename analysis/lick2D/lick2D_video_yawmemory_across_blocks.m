
function    lick2D_video_yawmemory_across_blocks()
    close all
    key=[];
        key.subject_id = 463190;

%     key.subject_id = 463190;
        key.session =4;

z= fetchn(TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & 'session>0','lick_peak_z');
histogram(z(~isnan(z)))
% lick_peak_z

T= fetch(TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & 'session>0' & 'lick_number=1' & 'flag_trial_has_licks_after_lickport_entrance=1' & 'flag_auto_water_settings=0','*');

%% After lickport entrance
subplot(2,2,1);

diff_first_previous=[];
diff_first_next=[];
diff_all_previous=[];
for i=2:1:numel(T)-1
    if T(i).current_trial_num_in_block==1
        diff_first_previous(end+1) = abs(T(i).lick_peak_yaw_avg_across_licks_after_lickportentrance - T(i-1).lick_peak_yaw_avg_across_licks_after_lickportentrance); %lick_yaw_lickbout_avg_for_licks_with_touch
        diff_first_next(end+1) = abs(T(i).lick_peak_yaw_avg_across_licks_after_lickportentrance - T(i+1).lick_peak_yaw_avg_across_licks_after_lickportentrance);
    elseif T(i).current_trial_num_in_block>=3
         diff_all_previous(end+1) = abs(T(i).lick_peak_yaw_avg_across_licks_after_lickportentrance - T(i-1).lick_peak_yaw_avg_across_licks_after_lickportentrance);
    end
end

hold on
histogram(diff_first_previous(~isnan(diff_first_previous)),[0:3:30],'Normalization','probability')
histogram(diff_first_next(~isnan(diff_first_next)),[0:3:30],'Normalization','probability')



%% Before lickport entrance
subplot(2,2,2);

diff_first_previous=[];
diff_first_next=[];
diff_all_previous=[];
for i=2:1:numel(T)-1
    if T(i).current_trial_num_in_block==1
        diff_first_previous(end+1) = abs(T(i).lick_peak_yaw_avg_across_licks_before_lickportentrance - T(i-1).lick_peak_yaw_avg_across_licks_before_lickportentrance); %lick_yaw_lickbout_avg_for_licks_with_touch
        diff_first_next(end+1) = abs(T(i).lick_peak_yaw_avg_across_licks_before_lickportentrance - T(i+1).lick_peak_yaw_avg_across_licks_before_lickportentrance);
    elseif T(i).current_trial_num_in_block>=3
         diff_all_previous(end+1) = abs(T(i).lick_peak_yaw_avg_across_licks_before_lickportentrance - T(i-1).lick_peak_yaw_avg_across_licks_before_lickportentrance);
    end
end

hold on
histogram(diff_first_previous(~isnan(diff_first_previous)),[0:3:30],'Normalization','probability')
histogram(diff_first_next(~isnan(diff_first_next)),[0:3:30],'Normalization','probability')
[h,p]=ttest(diff_first_previous,diff_first_next);


% T= fetch(TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & 'session>1' & 'lick_number_relative_to_lickport_entrance=-2' & 'flag_trial_has_licks_after_lickport_entrance=1' ,'*')
% % T= fetch(TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & 'lick_number_relative_to_firsttouch=-1' & 'flag_trial_has_licks_after_lickport_entrance=1' & 'flag_auto_water_settings=0','*')
% lick_peak_yaw_avg_across_licks_before_lickportentrance
% diff_first_previous=[];
% diff_first_next=[];
% diff_all_previous=[];
% diff_all_next=[];
% for i=2:1:numel(T)-1
%     if T(i).current_trial_num_in_block==1
%         diff_first_previous(end+1) = abs(T(i).lick_yaw_lickbout_avg - T(i-1).lick_yaw_lickbout_avg); %lick_peak_yaw
%         diff_first_next(end+1) = abs(T(i).lick_yaw_lickbout_avg - T(i+1).lick_yaw_lickbout_avg);
%     elseif T(i).current_trial_num_in_block>=3
%          diff_all_previous(end+1) = abs(T(i).lick_yaw_lickbout_avg - T(i-1).lick_yaw_lickbout_avg);
%     end
% end

% hold on
% histogram(diff_first_previous,[0:3:30],'Normalization','probability')
% histogram(diff_first_next,[0:3:30],'Normalization','probability')
% histogram(diff_all_previous,[0:1:30],'Normalization','probability')
