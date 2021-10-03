%% Behavioral stats
function lick2D_video_licking_stats_reward_increase_omission()
close all
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Lick2D\behavior\'];

% rel_behavior_trial = (EXP2.BehaviorTrialEvent*EXP2.SessionTrial  & 'trial_event_type="go"' & EXP2.TrialRewardSize) - TRACKING.TrackingTrialBad - IMG.Mesoscope;
rel_behavior_trial = (EXP2.BehaviorTrialEvent*EXP2.SessionTrial  & 'trial_event_type="go"' & EXP2.TrialRewardSize) - TRACKING.TrackingTrialBad & IMG.Mesoscope;

time_go = fetchn(rel_behavior_trial ,'trial_event_time','ORDER BY trial'); %relative to trial start

L_regular=[fetch(EXP2.ActionEvent*rel_behavior_trial & (EXP2.TrialRewardSize & 'reward_size_type="regular"'),'*')];
L_large=[fetch(EXP2.ActionEvent*rel_behavior_trial & (EXP2.TrialRewardSize & 'reward_size_type="large"'),'*')];
L_omission=[fetch(EXP2.ActionEvent*rel_behavior_trial & (EXP2.TrialRewardSize & 'reward_size_type="omission"'),'*')];

T_regular=numel(unique([L_regular.trial_uid]));
T_large=numel(unique([L_large.trial_uid]));
T_omission=numel(unique([L_omission.trial_uid]));


ValveTime_regular = mean(fetchn(EXP2.TrialRewardSize & 'reward_size_type="regular"' & rel_behavior_trial,'reward_size_valve_time'));
ValveTime_large = mean(fetchn(EXP2.TrialRewardSize & 'reward_size_type="large"' & rel_behavior_trial,'reward_size_valve_time'));
ValveTime_omission = mean(fetchn(EXP2.TrialRewardSize & 'reward_size_type="omission"' & rel_behavior_trial,'reward_size_valve_time'));

ValveTime_large/ValveTime_regular
% 
% unique([L_regular.trial_uid])
% for 



licks_time_electric_regular =[L_regular.action_event_time]  - [L_regular.trial_event_time];
licks_time_electric_large =[L_large.action_event_time]  - [L_large.trial_event_time];
licks_time_electric_omission =[L_omission.action_event_time]  - [L_omission.trial_event_time];


time_bins=-1:0.1:5;

subplot(2,2,1)
time_bins_centers=time_bins(1:end-1)+mean(diff(time_bins))/2;
h1=histogram(licks_time_electric_regular,time_bins);
y1 =h1.BinCounts/T_regular;
h2=histogram(licks_time_electric_large,time_bins);
y2 =h2.BinCounts/T_large;
bar(time_bins_centers,y1,'FaceColor',[0 0 0],'EdgeColor',[0 0 0],'BarWidth',1);
hold on;
bar(time_bins_centers,y2,'FaceColor',[1 0.5 0],'EdgeColor',[1 0.5 0],'BarWidth',1,'FaceAlpha',0.6);

% title(sprintf('Response time of tuned neurons'));
xlim([time_bins(1),time_bins(end)]);
ylim([0 0.5]);
ylabel(sprintf('Lick rate (licks/s)'));
xlabel('Lick time relative to lickport ascend (s)');
title(sprintf('Reward-increase trials\n %.1f licks/trial vs. %.1f on regular trials',sum(y2),sum(y1)),'Color',[1 0.5 0]);


subplot(2,2,2)
time_bins_centers=time_bins(1:end-1)+mean(diff(time_bins))/2;
h1=histogram(licks_time_electric_regular,time_bins);
y1 =h1.BinCounts/T_regular;
h2=histogram(licks_time_electric_omission,time_bins);
y2 =h2.BinCounts/T_omission;
bar(time_bins_centers,y1,'FaceColor',[0 0 0],'EdgeColor',[0 0 0],'BarWidth',1);
hold on;
bar(time_bins_centers,y2,'FaceColor',[0 0.7 0.2],'EdgeColor',[0 0.7 0.2],'BarWidth',1,'FaceAlpha',0.6);

% title(sprintf('Response time of tuned neurons'));
xlim([time_bins(1),time_bins(end)]);
ylim([0 0.5]);
ylabel(sprintf('Lick rate (licks/s)'));
xlabel('Lick time relative to lickport ascend (s)');
title(sprintf('Reward-omission trials\n %.1f licks/trial vs. %.1f on regular trials',sum(y2),sum(y1)),'Color',[0 0.7 0.2]);

filename='Lick2D_behavior_stats_reward_increase_omission_not_mesoscope';
if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);

