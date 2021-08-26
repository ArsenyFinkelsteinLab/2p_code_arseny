function [distance_bins,y_binned_signif, N_signif,N_all, idx_nonempty_bins] = fn_plot_distance_dependence(rel, distance_bins, flag_distance_flag, response_p_value, line_color)

rel = rel & 'response_distance_lateral_um<=150';

%% Plotting response from all neurons as dots
S=fetch( rel ,'*');
if flag_distance_flag==0 % lateral distance
    d_all=[S.response_distance_lateral_um];
elseif flag_distance_flag==1 % axial distance (depth)
    d_all=[S.response_distance_axial_um];
elseif flag_distance_flag==2 % 3D distance in a volume
    d_all=[S.response_distance_3d_um];
end

f_all =  [S.response_mean];
if flag_distance_flag==1 % axial distance (depth)
    plot(d_all + 10*rand(1,numel(d_all)) ,f_all,'.k'); % with some jitter
else
    plot(d_all ,f_all,'.k');
end


x=d_all;
y=f_all;
[N_all edges bin]=histcounts(x,distance_bins);
idx_nonempty_bins = N_all~=0;
for i_b = 1:1:numel(distance_bins)
    ix=find(bin==i_b);
    y_binned(i_b) = mean(y(ix));
end


%% Plotting response from all signficantly influenced neurons as dots


S_signif=fetch(rel & sprintf('response_p_value1 <%.10f',response_p_value),'*');
if flag_distance_flag==0 % lateral distance
    d_sig=[S_signif.response_distance_lateral_um];
elseif flag_distance_flag==1 % axial distance (depth)
    d_sig=[S_signif.response_distance_axial_um];
elseif flag_distance_flag==2 % 3D distance in a volume
    d_sig=[S_signif.response_distance_3d_um];
end

f_sig =  [S_signif.response_mean];
if flag_distance_flag==1 % axial distance (depth)
    plot(d_sig + 10*rand(1,numel(d_sig)) ,f_sig,'.r'); % with some jitter
else
    plot(d_sig ,f_sig,'.r'); % with some jitter
end

x=d_sig;
y=f_sig;
[N_signif edges bin]=histcounts(x,distance_bins);
for i_b = 1:1:numel(distance_bins)
    ix=find(bin==i_b);
    y_binned_signif(i_b) = mean(y(ix));
end



plot(distance_bins(~isnan(y_binned)),y_binned(~isnan(y_binned)),'-','Color',line_color,'LineWidth',2)

% plot(distance_bins,y_binned_signif,'Color',[1 0.75 0.75],'LineWidth',2)
% plot([0,max(distance_bins)],[0,0],'Color',[1 1 1],'LineWidth',1)
% xlabel('Distance from nearest target (\mum)');
% ylabel('\Delta F/F');

ylim([-0.1, 0.6]);
xlim([ min(distance_bins), max(distance_bins)]);


