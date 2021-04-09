function PLOT_Network_Degree_ON_LOCAL_CORR_MAP()
flag_response= 1; %0 all, 1 excitation, 2 inhibition

k_degree.max_distance_lateral =200;
k_degree.session_epoch_number=2;
k_degree.num_svd_components_removed=0;
k_degree.p_val = single(0.05);

k_corr_local.radius_size=200;
k_corr_local.session_epoch_type = 'behav_only'; % behav_only spont_only
k_corr_local.num_svd_components_removed=1;
rel_session = EXP2.Session & (STIMANAL.DirectOutDegree & IMG.Volumetric) & (EXP2.SessionEpoch& 'session_epoch_type="behav_only"') & (STIMANAL.NeuronOrControl & 'neurons_or_control=1' & 'num_targets>=30');


sessions = fetch(rel_session);

DATA_DEGREE_ALL=[];
DATA_CORR_ALL=[];

for i_s = 1:1:rel_session.count
    clf

    k_s = sessions(i_s);
    i_s;
    rel_degree = STIMANAL.DirectOutDegree*STIM.ROIResponseDirect  & (STIMANAL.NeuronOrControl & 'neurons_or_control=1') & k_degree & k_s;
    DATA_DEGREE = struct2table(fetch(rel_degree, '*'));
    %    numel(unique(DATA_DEGREE.roi_number))
    
    key_epoch = fetch(EXP2.SessionEpoch & k_s & k_corr_local);
    rel_corr_local = POP.ROICorrLocalPhoto  & k_s & k_corr_local & key_epoch;
    
    max_degree_session(i_s)=max([DATA_DEGREE.out_degree_excitatory1]);
        mean_degree_session(i_s)=mean([DATA_DEGREE.out_degree_excitatory1]);

    if max_degree_session(i_s)<50
        continue
    end
    
    if rel_corr_local.count==0
        continue
    end
    rel_corr_local =  rel_corr_local*IMG.ROI& key_epoch(1) & 'plane_num=1';
    
    DATA_CORR = struct2table(fetch(rel_corr_local, '*'));
    
    
    idx=[];
    for i_r=1:1:size(DATA_DEGREE,1)
        idx(i_r) = find(DATA_CORR.roi_number == DATA_DEGREE.roi_number(i_r));
    end
    DATA_CORR_ALL =[DATA_CORR_ALL; DATA_CORR(idx,:)];
    DATA_DEGREE_ALL =[DATA_DEGREE_ALL; DATA_DEGREE];

% DATA = struct2table(fetch(POP.ROICorrLocalPhoto*IMG.ROI  & k_corr_local & key_epoch(1),'*'));
pix2dist=1;

bins1 = prctile(DATA_CORR.corr_local_without_inner_ring, [0:5:100]);

%% MAP
[N,edges,bin]=histcounts(DATA_CORR.corr_local_without_inner_ring,bins1);
% ax1=axes('position',[position_x1(1), position_y1(1), panel_width1*2, panel_height1*2]);
my_colormap=jet(numel(bins1));
% my_colormap=plasma(numel(time_bins1));

subplot(3,3,[1,2,4,5])
hold on;

for i_roi=1:1:size(DATA_CORR,1)
    plot(DATA_CORR.roi_centroid_x(i_roi)*pix2dist, DATA_CORR.roi_centroid_y(i_roi)*pix2dist,'.','Color',my_colormap(bin(i_roi),:),'MarkerSize',7)
end
axis xy
set(gca,'YDir','reverse')
% title(sprintf('Motor map, left ALM\n n = %d tuned neurons (%.1f%%) \n',size(M,1), 100*size(M,1)/rel_all_good_cells.count   ));
% set(gca,'Xlim',[min(x_dim),max(x_dim)],'Xtick',[0, 800], 'Ylim',[min(y_dim),max(y_dim)],'Ytick',[0,800],'TickLength',[0.01,0],'TickDir','out')
axis equal
axis tight
xlabel('Anterior - Posterior (\mum)');
ylabel('Lateral - Medial (\mum)');
% title([ 'anm' num2str(key.subject_id) ' s' num2str(key.session) ' ' session_date filename_suffix]);


idx = find(DATA_DEGREE.out_degree_excitatory1>prctile(DATA_DEGREE.out_degree_excitatory1,95));
idx_corr_roi=[];
for i=1:1:numel(idx)
    current_roi =     DATA_DEGREE.roi_number(idx(i));
    idx_corr_roi(i) = find(DATA_CORR.roi_number == current_roi);
    plot(DATA_CORR.roi_centroid_x(idx_corr_roi(i) )*pix2dist, DATA_CORR.roi_centroid_y(idx_corr_roi(i) )*pix2dist,'o','Color',my_colormap(bin(idx_corr_roi(i) ),:),'MarkerSize',DATA_DEGREE.out_degree_excitatory1(idx(i))/5)
end
mean(DATA_CORR.corr_local_without_inner_ring(idx_corr_roi))

idx = find(DATA_DEGREE.out_degree_excitatory1<=prctile(DATA_DEGREE.out_degree_excitatory1,5));
idx_corr_roi=[];
for i=1:1:numel(idx)
    current_roi =     DATA_DEGREE.roi_number(idx(i));
    idx_corr_roi(i) = find(DATA_CORR.roi_number == current_roi);
    plot(DATA_CORR.roi_centroid_x(idx_corr_roi(i) )*pix2dist, DATA_CORR.roi_centroid_y(idx_corr_roi(i) )*pix2dist,'d','Color',my_colormap(bin(idx_corr_roi(i) ),:),'MarkerSize',7)
end
mean(DATA_CORR.corr_local_without_inner_ring(idx_corr_roi))

% Colorbar
% ax2=axes('position',[position_x2(4)+0.15, position_y2(1)+0.08, panel_width2, panel_height2/4]);
% colormap(ax2,my_colormap)
% % cb1 = colorbar(ax2,'Position',[position_x2(4)+0.15, position_y2(1)+0.1, panel_width2, panel_height2/4], 'Ticks',[0, 0.5, 1],...
% %     'TickLabels',[-5,0,5],'Location','NorthOutside');
% cb1 = colorbar(ax2,'Position',[position_x2(4)+0.15, position_y2(1)+0.1, panel_width2, panel_height2/4], 'Ticks',[0, 0.5, 1],...
%     'TickLabels',[],'Location','NorthOutside');
% axis off;

subplot(3,3,9)
mean_img_enhanced = fetch1(IMG.Plane & k_s & 'plane_num=1','mean_img_enhanced');
imagesc(mean_img_enhanced)
colormap(bone)
end
a=1