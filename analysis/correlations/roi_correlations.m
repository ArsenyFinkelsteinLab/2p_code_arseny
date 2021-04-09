function roi_correlations()
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\Photostim_traces\anm442411\coupled_2019-05-12\'];

close all;


rel=ANLI.ROICorr & (EXP2.SessionEpoch & 'session_epoch_type!="spont_photo"');

MatAll=fetch(rel,'*');

all_corr=[];
all_distance=[];

for i_se=1:1:rel.count
    
    mat_r = MatAll(i_se).mat_roi_corr;
    mat_pval = MatAll(i_se).mat_roi_corr_pval;
    mat_distance = MatAll(i_se).mat_distance;
    
    mat_r(isnan(mat_r))=0;
    temp=logical(tril(mat_r));
    idx_up_triangle=~temp;
    
    mean_corr(i_se)=mean(mat_r(idx_up_triangle));
    all_corr=[all_corr; mat_r(idx_up_triangle)];
    all_distance=[all_distance; mat_distance(idx_up_triangle)];
    
    %       histogram(mat_pval(idx_up_triangle))
    
end


idx_positive_r=all_corr>=0;
all_corr_positive=all_corr(idx_positive_r);
all_distance_positive=all_distance(idx_positive_r);

idx_negative_r=all_corr<0;
all_corr_negative=all_corr(idx_negative_r);
all_distance_negative=all_distance(idx_negative_r);


distance_bins_positive=[prctile(all_distance_positive,[0:1:100])];
distance_bins_negative=[prctile(all_distance_negative,[0:1:100])];

for i_d=1:1:numel(distance_bins_positive)-1
    idx=all_distance_positive>=(distance_bins_positive(i_d)) & all_distance_positive<(distance_bins_positive(i_d+1));
    r_binned_positive(i_d)=median(all_corr_positive(idx));
    bins_center_positive(i_d) = (distance_bins_positive(i_d) + distance_bins_positive(i_d+1))/2;
    
    idx=all_distance_negative>=(distance_bins_negative(i_d)) & all_distance_negative<(distance_bins_negative(i_d+1));
    r_binned_negative(i_d)=median(all_corr_negative(idx));
    bins_center_negative(i_d) = (distance_bins_negative(i_d) + distance_bins_negative(i_d+1))/2;
    
end

hold on
plot(bins_center_positive,r_binned_positive,'.r')
plot(bins_center_negative,r_binned_negative,'.b')

% histogram(mean_corr,8);

