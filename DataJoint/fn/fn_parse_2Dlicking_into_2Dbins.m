% function [x_idx, z_idx, mat_x, mat_z, x_bins, z_bins, pos_x, pos_z] = fn_parse_2Dlicking_into_2Dbins(key,number_of_bins)
function [x_idx, z_idx, mat_x, mat_z, x_bins_centers, z_bins_centers, pos_x, pos_z] = fn_parse_2Dlicking_into_2Dbins(key,number_of_bins)

%% Rescaling, rotation, and binning

if isempty(number_of_bins) % if number_of_bins is not given, compute it from here:
    [POS, number_of_bins] = fn_rescale_and_rotate_lickport_pos (key);
else % or use the number_of_bins provided by the fn_parse_2Dlicking_into_2Dbins function
    [POS, ~] = fn_rescale_and_rotate_lickport_pos (key);
end
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



%% Compute coverage, for subsampling
session_date = fetch1(EXP2.Session & key,'session_date');
filename = [ 'anm' num2str(key.subject_id) '_s' num2str(key.session) '_' session_date];

rand_x_jitter=pos_x+(rand(1,numel(pos_x))-0.5)./3;
rand_z_jitter=pos_z+(rand(1,numel(pos_x))-0.5)./3;

x_bins_original=x_bins;
z_bins_original=z_bins;

x_bins=prctile(rand_x_jitter,[0,33,66,100]);
z_bins=prctile(rand_z_jitter,[0,33,66,100]);

[hhhhh, ~, ~, x_idx, z_idx] = histcounts2(rand_x_jitter,rand_z_jitter,x_bins,z_bins);

%plot(pos_x,pos_z,'.')
subplot(2,2,1)

hold on
plot(pos_x,pos_z,'.b')
plot(rand_x_jitter,rand_z_jitter,'.r')
plot([x_bins(2),x_bins(2)],[z_bins(2)-1,z_bins(3)+1],'-k')
plot([x_bins(3),x_bins(3)],[z_bins(2)-1,z_bins(3)+1],'-k')
plot([x_bins(2)-1,x_bins(3)+1],[z_bins(2),z_bins(2)],'-k')
plot([x_bins(2)-1,x_bins(3)+1],[z_bins(3),z_bins(3)],'-k')
title(sprintf('anm%d %s session %d\nOriginal position',key.subject_id, session_date, key.session),'FontSize',10);

subplot(2,2,2)
imagesc(hhhhh)
caxis([0 max(hhhhh(:))]); % Scale the lowest value (deep blue) to 0
colormap(parula)
    
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Lick2D\behavior\lickport_position_3binning\'];

if isempty(dir(dir_current_fig))
    mkdir (dir_current_fig)
end
%
figure_name_out=[ dir_current_fig filename '_lickport'];
eval(['print ', figure_name_out, ' -dtiff  -r300']);
% eval(['print ', figure_name_out, ' -dpdf -r200']);
close all;

mat_x=repmat(x_bins_centers,key.number_of_bins,1);
mat_z=repmat(z_bins_centers',1,key.number_of_bins);


