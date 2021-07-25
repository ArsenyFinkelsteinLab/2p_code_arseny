
function    lick2D_video_yaw_early_vs_nonearly()
clf
key=[];
key.subject_id = 463189;
% key.subject_id = 464724;


sessions_list = (unique(fetchn(TRACKING.VideoNthLickTrial & key, 'session')));


subplot(2,3,1)
k.session = sessions_list(1);
licks_first_session= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & k)-TRACKING.VideoGroomingTrial,'lick_time_onset');
k.session = sessions_list(end);
licks_last_session= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & k)-TRACKING.VideoGroomingTrial,'lick_time_onset');
hold on
time_bins=-2:0.2:10;
histogram(licks_first_session,time_bins,'Normalization','probability','FaceColor',[1.00,0.41,0.16])
histogram(licks_last_session,time_bins,'Normalization','probability','FaceColor',[0.00,0.45,0.74])
legend({'session 1', sprintf('session %d',sessions_list(end))});
xlabel(sprintf('Lick time, \nrelative to target presentation (s)'));
ylabel('Proportion of licks');


subplot(2,3,2)
k.session = sessions_list(1);
licks_first_session= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & k & 'lick_number_relative_to_firsttouch=1')-TRACKING.VideoGroomingTrial,'lick_time_onset');
k.session = sessions_list(end);
licks_last_session= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & k & 'lick_number_relative_to_firsttouch=1')-TRACKING.VideoGroomingTrial,'lick_time_onset');
hold on
time_bins=0:0.1:10;
histogram(licks_first_session,time_bins,'Normalization','probability','FaceColor',[1.00,0.41,0.16])
histogram(licks_last_session,time_bins,'Normalization','probability','FaceColor',[0.00,0.45,0.74])
legend({'session 1', sprintf('session %d',sessions_list(end))});
xlabel(sprintf('First contact time, \nrelative to target presentation (s)'));
ylabel('Proportion of licks');


for i_ses = 1:1:numel(sessions_list)
    key.session = sessions_list(i_ses);
    lick_onset_touch= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & 'lick_number_relative_to_firsttouch=0')-TRACKING.VideoGroomingTrial,'lick_time_onset');
    across_sessions.lick_onset_touch.mean(i_ses)=nanmedian(lick_onset_touch);
    across_sessions.lick_onset_touch.stem(i_ses)=nanstd(lick_onset_touch)./sqrt(numel(lick_onset_touch));
    
    
    lick_onset_after_target_present= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & 'lick_number_relative_to_lickport_entrance=0')-TRACKING.VideoGroomingTrial,'lick_time_onset');
    across_sessions.lick_onset_target_present.mean(i_ses)=nanmedian(lick_onset_after_target_present);
    across_sessions.lick_onset_target_present.stem(i_ses)=nanstd(lick_onset_after_target_present)./sqrt(numel(lick_onset_after_target_present));

    
    
    trials_list= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & 'lick_number=1')-TRACKING.VideoGroomingTrial,'trial');
    early_licks=[];
    
    T = fetch((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key )-TRACKING.VideoGroomingTrial,'*');
    
    yaw_early_std=[];
    yaw_late_std=[];
    
    for i_tr=1:1:numel(trials_list)
        idx_this_trial = [T.trial]==trials_list(i_tr);
        
        lick_yaw_lickbout = [T(idx_this_trial).lick_yaw_lickbout];
        
        idx_early =[T(idx_this_trial).lick_number_relative_to_lickport_entrance]<0;
        idx_late =[T(idx_this_trial).lick_number_relative_to_lickport_entrance]>=0;
        
        
        num_of_not_nan_licks = sum(~isnan(lick_yaw_lickbout(idx_early)));
        if num_of_not_nan_licks>1
            yaw_early_std(end+1) =nanstd(lick_yaw_lickbout(idx_early));%/sqrt(num_of_not_nan_licks);
            
        end
        
        num_of_not_nan_licks = sum(~isnan(lick_yaw_lickbout(idx_late)));
        if  num_of_not_nan_licks>1
            yaw_late_std(end+1) =nanstd(lick_yaw_lickbout(idx_late));%/sqrt(num_of_not_nan_licks);
        end
        %         [T(idx_this_trial).lick_number_relative_to_lickport_entrance]<0)
        
        
        early_licks(i_tr) =sum([T(idx_this_trial).lick_number_relative_to_lickport_entrance]<0);
        %         kk.trial=trials(i_tr);
        %         early_licks(i_tr) = numel(fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & kk & 'lick_number_relative_to_lickport_entrance<0')-TRACKING.VideoGroomingTrial,'lick_time_onset'));
        
    end
    across_sessions.num_of_early_licks.mean(i_ses)=mean(early_licks);
    across_sessions.num_of_early_licks.stem(i_ses)=nanstd(early_licks)./sqrt(numel(trials_list));
    
    across_sessions.yaw_std_early.mean(i_ses)=nanmean(yaw_early_std);
    across_sessions.yaw_std_early.stem(i_ses)=nanstd(yaw_early_std)./sqrt(numel(trials_list));
    
    
    across_sessions.yaw_std_late.mean(i_ses)=nanmean(yaw_late_std);
    across_sessions.yaw_std_late.stem(i_ses)=nanstd(yaw_late_std)./sqrt(numel(trials_list));
end

subplot(2,3,3)
hold on
shadedErrorBar(1:1:numel(sessions_list),across_sessions.num_of_early_licks.mean,across_sessions.num_of_early_licks.stem,'lineprops',{'-','Color',[0 0 1]});
% plot(across_training{1}.within_block,'-','Color',[0.00,0.45,0.74])
% legend({'across', 'within'});
xlabel('Session');
ylabel(sprintf('Number of early licks in trial'));





subplot(2,3,4)
hold on
shadedErrorBar(1:1:numel(sessions_list),across_sessions.lick_onset_target_present.mean,across_sessions.lick_onset_target_present.stem,'lineprops',{'-','Color',[0 0 0]})
% plot(across_training{1}.within_block,'-','Color',[0.00,0.45,0.74])
% legend({'across', 'within'});
xlabel('Session');
ylabel(sprintf('First lick time, \nrelative to target presentation (s)'));


subplot(2,3,5)
hold on
shadedErrorBar(1:1:numel(sessions_list),across_sessions.lick_onset_touch.mean,across_sessions.lick_onset_touch.stem,'lineprops',{'-','Color',[0.5 0.5 0.5]})
% plot(across_training{1}.within_block,'-','Color',[0.00,0.45,0.74])
% legend({'across', 'within'});
xlabel('Session');
ylabel(sprintf('First contact time, \nrelative to target presentation (s)'));


subplot(2,3,6)
hold on
h(1)=shadedErrorBar(1:1:numel(sessions_list),across_sessions.yaw_std_early.mean ,across_sessions.yaw_std_early.stem,'lineprops',{'-','Color',[0 0 1]})
h(2)=shadedErrorBar(1:1:numel(sessions_list),across_sessions.yaw_std_late.mean ,across_sessions.yaw_std_late.stem,'lineprops',{'-','Color',[1 0 0]})
% plot(across_training{1}.within_block,'-','Color',[0.00,0.45,0.74])
legend([h(1).mainLine h(2).mainLine], 'early licks', 'non-early')
xlabel('Session');
ylabel(sprintf('Azimuth variability (std)'));
