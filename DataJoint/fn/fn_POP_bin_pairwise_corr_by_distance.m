function key = fn_POP_bin_pairwise_corr_by_distance (key, rho, distance, threshold_for_event_vector, i_th,i_c,corr_histogram_bins, distance_bins,num_svd_components_removed_vector)

colors=inferno(numel(num_svd_components_removed_vector));


%% Distance dependence
idxnan=isnan(rho);
rho(idxnan)=0;  %because logical cannot be NaNs
temp=logical(tril(rho));
idx_up_triangle=~temp; 
rho(idxnan)=NaN;  %because logical cannot be NaNs

all_corr = rho(idx_up_triangle);
all_distance = distance(idx_up_triangle);

idx_positive_r=all_corr>0;
% all_corr_positive=all_corr(idx_positive_r);
% all_distance_positive=all_distance(idx_positive_r);

idx_negative_r=all_corr<=0;
% all_corr_negative=all_corr(idx_negative_r);
% all_distance_negative=all_distance(idx_negative_r);


r_binned_all=zeros(1,numel(distance_bins)-1);
r_binned_positive=zeros(1,numel(distance_bins)-1);
r_binned_negative=zeros(1,numel(distance_bins)-1);
corr_histogram_per_distance=zeros(numel(distance_bins)-1,numel(corr_histogram_bins)-1);


bins_center=zeros(1,numel(distance_bins)-1);
for i_d=1:1:numel(distance_bins)-1
    
    [r_binned_all(i_d),r_binned_positive(i_d),r_binned_negative(i_d),corr_hist]=  fn_POP_binning_distance_corr(distance_bins,corr_histogram_bins, all_distance, i_d, all_corr, idx_positive_r, idx_negative_r);
    corr_histogram_per_distance(i_d,:) = corr_hist;
    bins_center(i_d) = (distance_bins(i_d) + distance_bins(i_d+1))/2;
    
end

key.distance_corr_all = r_binned_all;
key.distance_corr_positive     = r_binned_positive;
key.distance_corr_negative     = r_binned_negative;
key.corr_histogram_per_distance = corr_histogram_per_distance;

key.corr_histogram =histcounts(all_corr(:),corr_histogram_bins);
key.corr_histogram_bins=corr_histogram_bins;



%% Plot

session_date = fetch1(EXP2.Session & key,'session_date');

session_epoch_type = fetch1(EXP2.SessionEpoch & key, 'session_epoch_type');
if strcmp(session_epoch_type,'spont_only')
    session_epoch_label = 'Spontaneous';
elseif strcmp(session_epoch_type,'behav_only')
    session_epoch_label = 'Behavior';
elseif strcmp(session_epoch_type,'spont_photo')
    session_epoch_label = 'Spontaneous with Photostimulation';
end


subplot(numel(threshold_for_event_vector),3,((i_th-1)*3+1))
hold on
if i_c==1
    plot([bins_center(1),bins_center(end)],[0,0],'-r');
end
    
plot(bins_center,r_binned_all,'-','Color',colors(i_c,:))
plot(bins_center,r_binned_all,'.','Color',colors(i_c,:))
ylabel(sprintf('Pairwise corr.\n (all)'));
% try
% ylim([min([0,min(r_binned_all)]),max(r_binned_all)]);
% catch
% end
xlim([0 max(all_distance)]);
xlabel('Lateral Distance (\mum)');

if i_th==1
    title(sprintf('anm%d session %d %s\n%s %d \n threshold =%.2f', key.subject_id,key.session,session_date,session_epoch_label, key.session_epoch_number,  threshold_for_event_vector(i_th)));
else
    title(sprintf('Threshold for event = %.2f ',threshold_for_event_vector(i_th)));
end
% ylim([-0.02,0.2]);


subplot(numel(threshold_for_event_vector),3,((i_th-1)*3+2))
hold on
ylabel(sprintf('Pairwise corr.\n (positive)'));
plot(bins_center,r_binned_positive,'-','Color',colors(i_c,:))
plot(bins_center,r_binned_positive,'.','Color',colors(i_c,:))
xlabel('Lateral Distance (\mum)');
xlim([0 max(all_distance)]);

subplot(numel(threshold_for_event_vector),3,((i_th-1)*3+3))
hold on
xlabel('Lateral Distance (\mum)');
xlim([0 max(all_distance)]);
plot(bins_center,r_binned_negative,'-','Color',colors(i_c,:))
plot(bins_center,r_binned_negative,'.','Color',colors(i_c,:))
ylabel(sprintf('Pairwise corr.\n (negative)'));

end