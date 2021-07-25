
function    lick2D_video_yawmemory_across_blocks2()
clf
key=[];
% key.subject_id = 464724;

key.subject_id = 463189;



% z= fetchn(TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & 'session>0','lick_peak_z');
% histogram(z(~isnan(z)))
% lick_peak_z

rel = (TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock*EXP2.TrialLickPort & key & 'flag_trial_has_licks_after_lickport_entrance=1' & 'flag_auto_water_settings=0') -TRACKING.VideoGroomingTrial;

subjects_list = (unique(fetchn(rel, 'subject_id')));


% T= fetch(TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock & key & 'session>0' & 'flag_trial_has_licks_after_lickport_entrance=1' & 'flag_auto_water_settings=0','*');

%% After lickport entrance

diff_within_12_block_previous=[];
diff_within_23_block_previous=[];
diff_across_block_previous=[];
yaw_all_before=[];
yaw_all_after=[];

across_training =[];
for i_sub=1:1:numel(subjects_list)
    key.subject_id = subjects_list(i_sub);
    sessions_list = (unique(fetchn(rel & key, 'session')));
    for i_ses = 1:1:numel(sessions_list)
        key.session = sessions_list(i_ses);
        T= fetch(rel & key & 'lick_number=1','*');
        yaw_all_before=[yaw_all_before; fetchn(rel & key & 'lick_number_relative_to_lickport_entrance<0','lick_yaw_lickbout')];
        yaw_all_after= [yaw_all_after; fetchn(rel & key & 'lick_number_relative_to_lickport_entrance>=0','lick_yaw_lickbout')];
        
        trials_list = (unique(fetchn(rel & key, 'trial')));
        for i_tr=2:1:numel(trials_list)-1
            idx_this_trial = [T.trial]==trials_list(i_tr);
            idx_prev_trial = [T.trial]==trials_list(i_tr-1);
            
            Tthis = T(idx_this_trial);
            Tprev = T(idx_prev_trial);
            
            this_x_bin =   find(Tthis.lickport_pos_x_bins== Tthis.lickport_pos_x);
            prev_x_bin =   find(Tprev.lickport_pos_x_bins== Tprev.lickport_pos_x);
            
            
            if Tthis(1).current_trial_num_in_block==1 % a new trial block
                if (this_x_bin==1 && prev_x_bin==numel(Tprev.lickport_pos_x_bins)) || (this_x_bin==numel(Tthis.lickport_pos_x_bins) && prev_x_bin==1)
                    diff_across_block_previous(end+1) = abs(Tthis(1).lick_yaw_lickbout_avg_across_licks_before_lickportentrance - Tprev(1).lick_yaw_lickbout_avg_across_licks_after_lickportentrance); %lick_yaw_lickbout_avg_for_licks_with_touch
                end
            elseif Tthis(1).current_trial_num_in_block==2
                if (this_x_bin==1)  || (this_x_bin==numel(Tthis.lickport_pos_x_bins))
                    diff_within_12_block_previous(end+1) = abs(Tthis(1).lick_yaw_lickbout_avg_across_licks_before_lickportentrance - Tprev(1).lick_yaw_lickbout_avg_across_licks_after_lickportentrance);
                end
            elseif Tthis(1).current_trial_num_in_block==3
                if (this_x_bin==1)  || (this_x_bin==numel(Tthis.lickport_pos_x_bins))
                    diff_within_23_block_previous(end+1) = abs(Tthis(1).lick_yaw_lickbout_avg_across_licks_before_lickportentrance - Tprev(1).lick_yaw_lickbout_avg_across_licks_after_lickportentrance);
                end
            end
        end
        across_training{i_sub}.across_block.mean(i_ses) = nanmedian(diff_across_block_previous);
        across_training{i_sub}.across_block.stem(i_ses) = nanstd(diff_across_block_previous)/sqrt(numel(diff_across_block_previous));

        across_training{i_sub}.within_12_block.mean(i_ses) = nanmedian(diff_within_12_block_previous);
        across_training{i_sub}.within_12_block.stem(i_ses) = nanstd(diff_within_12_block_previous)/sqrt(numel(diff_within_12_block_previous));
        
          across_training{i_sub}.within_23_block.mean(i_ses) = nanmedian(diff_within_23_block_previous);
        across_training{i_sub}.within_23_block.stem(i_ses) = nanstd(diff_within_23_block_previous)/sqrt(numel(diff_within_23_block_previous));

    end
end


% subplot(2,2,1);
% hold on
% histogram(diff_across_block_previous(~isnan(diff_across_block_previous)),[0:5:30],'Normalization','probability','FaceColor',[1.00,0.41,0.16])
% histogram(diff_within_block_previous(~isnan(diff_within_block_previous)),[0:5:30],'Normalization','probability','FaceColor',[0.00,0.45,0.74])
% legend({'across', 'within'});
% xlabel('Difference in Azimuth (deg)');
% ylabel('Proportion of trials');

subplot(2,2,2);
hold on
h(1)=shadedErrorBar(1:1:numel(sessions_list),across_training{1}.across_block.mean ,across_training{1}.across_block.stem,'lineprops',{'-','Color',[0 0 0]})
h(2)=shadedErrorBar(1:1:numel(sessions_list),across_training{1}.within_12_block.mean ,across_training{1}.within_12_block.stem,'lineprops',{'-','Color',[1 0 0]})
h(3)=shadedErrorBar(1:1:numel(sessions_list),across_training{1}.within_23_block.mean ,across_training{1}.within_23_block.stem,'lineprops',{'-','Color',[0 0 1]})
legend([h(1).mainLine h(2).mainLine, h(3).mainLine], 'across blocks', 'within block, trial 1 vs. 2','within block, trial 2 vs. 3')

% 
% plot(across_training{1}.across_block.mean,'-','Color',[1.00,0.41,0.16])
% plot(across_training{1}.within_block.mean,'-','Color',[0.00,0.45,0.74])
% legend({'across', 'within'});
xlabel('Session #');
ylabel('Difference in Azimuth (deg)');
ylim([0,30])

subplot(2,2,1);
hold on
histogram(yaw_all_before(~isnan(yaw_all_before)),[-30:3:30],'Normalization','probability','FaceColor',[1.00,0.41,0.16])
histogram(yaw_all_after(~isnan(yaw_all_after)),[-30:3:30],'Normalization','probability','FaceColor',[0.00,0.45,0.74])
legend({'early licks', 'non early'});
xlabel('Azimuth (deg)');
ylabel('Proportion of trials');

% hold on
% histogram(diff_across_block_previous(~isnan(diff_across_block_previous)),[0:3:30],'Normalization','probability')
% histogram(diff_within_block_previous(~isnan(diff_within_block_previous)),[0:3:30],'Normalization','probability')
% legend({'across', 'within'});


%