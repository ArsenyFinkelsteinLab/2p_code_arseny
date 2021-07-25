%% Behavioral stats
function lick2D_video_licking_stats()
close all
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Lick2D\behavior\'];

subplot(2,2,1)
time_bins=-2:0.1:5;
licks= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock )-TRACKING.VideoGroomingTrial,'lick_time_onset');
histogram(licks,time_bins)
xlabel(sprintf('Time of all licks \nrelative to spout entrance (s)'));
ylabel('Licks');


subplot(2,2,2);
time_bins=0:0.1:3;
lick_onset= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock)-TRACKING.VideoGroomingTrial & 'lick_number_relative_to_firsttouch=1','lick_time_onset');
histogram(lick_onset,time_bins)
xlabel(sprintf('Time of first lick with contact\nrelative to spout entrance (s)'));
ylabel('Licks');
xlim([0,3]);

subplot(2,2,4);
time_bins=0:0.1:3;
lick_onset= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock)-TRACKING.VideoGroomingTrial & 'lick_number_with_touch_relative_to_reward=1','lick_time_onset');
histogram(lick_onset,time_bins)
xlabel(sprintf('Time of first rewarded lick\nrelative to spout entrance (s)'));
ylabel('Licks');
xlim([0,3]);


filename='Lick2D_behavior_stats';
if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
figure_name_out=[ dir_current_fig filename];
eval(['print ', figure_name_out, ' -dtiff  -r200']);

% subplot(2,2,3)
% licks= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock )-TRACKING.VideoGroomingTrial,'lick_time_onset_relative_firstlick_after_lickportentrance');
% histogram(licks,time_bins)
% xlabel(sprintf('Time of all licks \nrelative to first lick after spout enntrance (s)'));
% ylabel('Licks');
%
% subplot(2,2,2);
% time_bins=0:0.1:3;
% lick_onset= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock)-TRACKING.VideoGroomingTrial & 'lick_number_relative_to_lickport_entrance=0','lick_time_onset');
% histogram(lick_onset,time_bins)
% xlabel(sprintf('Time of first lick\nrelative to spout enntrance (s)'));
% ylabel('Licks');
% xlim([0,3]);



% subplot(2,2,3)
% licks= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock )-TRACKING.VideoGroomingTrial,'lick_time_onset_relative_firstlick_after_lickportentrance');
% histogram(licks,time_bins)
% xlabel(sprintf('Time of all licks \nrelative to first lick after spout enntrance (s)'));
% ylabel('Licks');
%
% subplot(2,2,2);
% time_bins=0:0.1:3;
% lick_onset= fetchn((TRACKING.VideoNthLickTrial*EXP2.SessionTrial*EXP2.TrialLickBlock)-TRACKING.VideoGroomingTrial & 'lick_number_relative_to_lickport_entrance=0','lick_time_onset');
% histogram(lick_onset,time_bins)
% xlabel(sprintf('Time of first lick\nrelative to spout enntrance (s)'));
% ylabel('Licks');
% xlim([0,3]);
%
