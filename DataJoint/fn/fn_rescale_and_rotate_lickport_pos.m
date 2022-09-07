function [POS, number_of_bins] = fn_rescale_and_rotate_lickport_pos (key)

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Lick2D\behavior\lickport_position\'];

LickPort=fetch((EXP2.TrialLickPort & key)-TRACKING.VideoGroomingTrial,'*');
number_of_bins = round(sqrt(max([LickPort.lickport_pos_number])));
idx_trials_for_boundaries = 150:numel(LickPort);


% Rescale and center the positions
%----------------------------
pos_x = [LickPort.lickport_pos_x];
pos_z = [LickPort.lickport_pos_z];

x_scaling = max(pos_x(idx_trials_for_boundaries)) - min(pos_x(idx_trials_for_boundaries));
z_scaling = max(pos_z(idx_trials_for_boundaries)) - min(pos_z(idx_trials_for_boundaries));


pos_x = pos_x-min(pos_x(idx_trials_for_boundaries));
pos_z = pos_z-min(pos_z(idx_trials_for_boundaries));


pos_x = pos_x/x_scaling;
pos_z = pos_z/z_scaling;



pos_x = 2*(pos_x-0.5);
pos_z = 2*(pos_z-0.5);

pos_x_original = pos_x;
pos_z_original = pos_z;
% Create rotation matrix to rotate the plane, so that it will be "straight" in egocentric coordinates
%----------------------------
roll = mean(fetchn((EXP2.TrialLickBlock & key) - TRACKING.VideoGroomingTrial,'roll_deg'));
if isnan(roll) %if there is no roll
roll=0;
end

R = [cosd(roll) -sind(roll); sind(roll) cosd(roll)];
for i_pos = 1:1:numel(pos_x)
    point = [pos_x(i_pos);pos_z(i_pos)];
    rotpoint = R*point;
    pos_x(i_pos) = rotpoint(1);
    pos_z(i_pos) = rotpoint(2);
end


% Rescale and center the positions again after rotation
%----------------------------
x_scaling = max(pos_x(idx_trials_for_boundaries)) - min(pos_x(idx_trials_for_boundaries));
z_scaling = max(pos_z(idx_trials_for_boundaries)) - min(pos_z(idx_trials_for_boundaries));

pos_x = pos_x-min(pos_x(idx_trials_for_boundaries));
pos_z = pos_z-min(pos_z(idx_trials_for_boundaries));


pos_x = pos_x/x_scaling;
pos_z = pos_z/z_scaling;

pos_x = 2*(pos_x-0.5);
pos_z = 2*(pos_z-0.5);


POS.pos_x = pos_x;
POS.pos_z = pos_z;
POS.pos_x_original = pos_x_original;
POS.pos_z_original = pos_z_original;


%% Plotting lickport positions
session_date = fetch1(EXP2.Session & key,'session_date');

filename = [ 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date]

subplot(2,2,1)
plot(pos_x_original+rand(1,numel(pos_x_original))/10, pos_z_original+rand(1,numel(pos_x_original))/10,'.')
xlabel('X');
ylabel('Z');
title(sprintf('anm%d %s session %d\nOriginal position',key.subject_id, session_date, key.session),'FontSize',10);

subplot(2,2,2)
plot(pos_x+rand(1,numel(pos_x))/10, pos_z+rand(1,numel(pos_x))/10,'.')
xlabel('X');
ylabel('Z');
title('Rotated position','FontSize',10);



if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename '_lickport'];
eval(['print ', figure_name_out, ' -dtiff  -r300']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);
close all;
