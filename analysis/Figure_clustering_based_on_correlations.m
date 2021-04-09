function Figure_clustering_based_on_correlations()
close all;

dir_save_figure=['Z:\users\Arseny\Projects\Learning\imaging2p\Results\PV_corr_intersect_ensemble_extraction_avg_maps\AF09_anm437545\'];
set(gcf,'color',[1 1 1]);

%Graphics
%---------------------------------
figure;
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

panel_width=0.05;
panel_height=0.065;
horizontal_distance=0.075;
vertical_distance=0.31;

position_x(1)=0.13;

position_y(1)=0.8;
position_y(2)=position_y(1)-vertical_distance;


columns2plot=12;
min_cluster_percent=2.5;



% % fetch Param
Param = struct2table(fetch (ANL.Parameters,'*'));
% time = Param.parameter_value{(strcmp('psth_t_vector',Param.parameter_name))};
% psth_time_bin = Param.parameter_value{(strcmp('psth_time_bin',Param.parameter_name))};
% smooth_time = Param.parameter_value{(strcmp('smooth_time_cell_psth_for_clustering',Param.parameter_name))};
% smooth_bins=ceil(smooth_time/psth_time_bin);


for i_session=1:1:12
    key.session = i_session;
    
    rel_cluster=ANLI.ROICluster & key;
    
    rel_PSTH=ANLI.FPSTHaverage & rel_cluster;
    
    %hit
    L.PSTH{1} =cell2mat(fetchn(rel_PSTH  & 'trial_type_name="l"' & 'outcome="hit"', 'psth_avg', 'ORDER BY roi_number'));
    R.PSTH{1} =cell2mat(fetchn(rel_PSTH  & 'trial_type_name="r"' & 'outcome="hit"', 'psth_avg', 'ORDER BY roi_number'));
    
    %miss
    L.PSTH{2} =cell2mat(fetchn(rel_PSTH  & 'trial_type_name="l"' & 'outcome="miss"', 'psth_avg', 'ORDER BY roi_number'));
    R.PSTH{2} =cell2mat(fetchn(rel_PSTH  & 'trial_type_name="r"' & 'outcome="miss"', 'psth_avg', 'ORDER BY roi_number'));
    
    % L.num_trials{1} = (fetchn(rel  & 'trial_type_name="l"', 'num_trials_averaged', 'ORDER BY unit_uid'));
    % R.num_trials{1} = (fetchn(rel  & 'trial_type_name="r"', 'num_trials_averaged', 'ORDER BY unit_uid'));
    
    peak_LR_hit_units = nanmax([L.PSTH{1},R.PSTH{1},L.PSTH{2},R.PSTH{2},],[],2);
    
    
    cl_id = fetchn(rel_cluster, 'roi_cluster_id', 'ORDER BY roi_number');
    
    typical_psth_timestamps =fetch1(ANLI.FPSTHMatrix & rel_PSTH , 'typical_psth_timestamps');
    idx_time2plot = (typical_psth_timestamps>= -3 & (typical_psth_timestamps<=2));
    
    time2plot = typical_psth_timestamps(idx_time2plot);
    
    
    
    % rel_unit=(EPHYS.Unit);
    % rel_cluster = (ANL.UnitHierarCluster3 * rel_unit.proj('unit_quality->temp','unit_uid')) & k;
    % key_cluster = fetch(rel_cluster);
    % UnitCluster  = struct2table(fetch(rel_cluster,'*', 'ORDER BY unit_uid'));
    % key_cluster = rmfield(key_cluster,{'hemisphere','brain_area','cell_type','unit_quality','training_type','heirar_cluster_time_st','heirar_cluster_time_end'});
    % % idx_time2plot = (time>= UnitCluster.heirar_cluster_time_st(1)) & (time<=UnitCluster.heirar_cluster_time_end(1));
    %
    % time2plot = time(idx_time2plot);
    % %fetch Unit
    % Unit = struct2table(fetch((EPHYS.Unit * EPHYS.UnitPosition * EXP.SessionTraining * EXP.SessionID * ANL.IncludeSession- ANL.ExcludeSession) & key_cluster & ANL.IncludeUnit ,'*', 'ORDER BY unit_uid'));
    % session_uid = unique(Unit.session_uid);
    %
    % L.labels = {'hit','miss','ignore'};
    % R.labels = {'hit','miss','ignore'};
    %
    % %% Hit
    % % fetch and smooth PSTH
    % rel= ((ANL.PSTHAdaptiveAverage * EPHYS.Unit) & key_cluster & ANL.IncludeUnit * ANL.IncludeSession- ANL.ExcludeSession) & 'outcome="hit"' ;
    % L.PSTH{1} = movmean(cell2mat(fetchn(rel  & 'trial_type_name="l"', 'psth_avg', 'ORDER BY unit_uid')) ,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
    % R.PSTH{1} = movmean(cell2mat(fetchn(rel  & 'trial_type_name="r"', 'psth_avg', 'ORDER BY unit_uid')) ,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
    %
    % L.num_trials{1} = (fetchn(rel  & 'trial_type_name="l"', 'num_trials_averaged', 'ORDER BY unit_uid'));
    % R.num_trials{1} = (fetchn(rel  & 'trial_type_name="r"', 'num_trials_averaged', 'ORDER BY unit_uid'));
    %
    % peak_LR_hit_units = nanmax([L.PSTH{1},R.PSTH{1}],[],2);
    %
    % %% Miss
    % % fetch and smooth PSTH
    % rel= ((ANL.PSTHAverageLR * EPHYS.Unit) & key_cluster & ANL.IncludeUnit * ANL.IncludeSession- ANL.ExcludeSession) & 'outcome="miss"';
    % L.PSTH{2} = movmean(cell2mat(fetchn(rel  & 'trial_type_name="l"', 'psth_avg', 'ORDER BY unit_uid')) ,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
    % R.PSTH{2} = movmean(cell2mat(fetchn(rel  & 'trial_type_name="r"', 'psth_avg', 'ORDER BY unit_uid')) ,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
    % L.num_trials{2} = (fetchn(rel  & 'trial_type_name="l"', 'num_trials_averaged', 'ORDER BY unit_uid'));
    % R.num_trials{2} = (fetchn(rel  & 'trial_type_name="r"', 'num_trials_averaged', 'ORDER BY unit_uid'));
    %
    %
    % % %% Ignore
    % % % fetch and smooth PSTH
    % % rel= ((ANL.PSTHAdaptiveAverage * EPHYS.Unit) & key_cluster) & 'outcome="ignore"';
    % % L.PSTH{3} = movmean(cell2mat(fetchn(rel  & 'trial_type_name="l"', 'psth_avg', 'ORDER BY unit_uid')) ,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
    % % R.PSTH{3} = movmean(cell2mat(fetchn(rel  & 'trial_type_name="r"', 'psth_avg', 'ORDER BY unit_uid')) ,[smooth_bins 0], 2, 'omitnan','Endpoints','shrink');
    % % L.num_trials{3} = (fetchn(rel  & 'trial_type_name="l"', 'num_trials_averaged', 'ORDER BY unit_uid'));
    % % R.num_trials{3} = (fetchn(rel  & 'trial_type_name="r"', 'num_trials_averaged', 'ORDER BY unit_uid'));
    
    
    
    % Select cluster to plot
    % cl_id=UnitCluster.heirar_cluster_id;
    cluster_percent=100*histcounts(cl_id,1:1:numel(unique(cl_id))+1)/numel(cl_id);
    clusters_2plot = find(cluster_percent>=min_cluster_percent);
    [~,cluster_order] = sort (cluster_percent(clusters_2plot),'descend');
    cluster_order=cluster_order(1:min([numel(clusters_2plot),columns2plot*2]));
    
    axes('position',[position_x(1), 0.93, panel_width, panel_height]);
    percent_of_all = sum(cluster_percent(clusters_2plot));
    % text( 0,0 , sprintf('%s %s side   Training: %s    CellQuality: %s  Cell-type: %s    \n \n Includes: %d units,   %.1f %% in these clusters:' ,...
    %     key.brain_area, key.hemisphere, key.training_type, key.unit_quality, key.cell_type, size(UnitCluster,1), percent_of_all),'HorizontalAlignment','Left','FontSize', 10);
    axis off;
    box off;
    
    plot_counter=0;
    for ii = cluster_order
        i = clusters_2plot(ii);
        idx2plot = find(cl_id==i);
        
        
        axes('position',[position_x(1)+horizontal_distance*(mod(plot_counter,columns2plot)), position_y(1)+0.02, panel_width, panel_height*0.6]);
        title(sprintf('Cluster %d \n %.1f %% cells\n',plot_counter+1, cluster_percent(i) ),'FontSize',8);
        axis off; box off;
        xl=([0 3]);
        xlim(xl);
        yl=[0 1];
        ylim(yl);
        if mod(plot_counter,columns2plot)==0
            text(xl(1)-diff(xl)*0.75, yl(1)+diff(yl)*1.9, 'a', ...
                'fontsize', 12, 'fontname', 'helvetica', 'fontweight', 'bold');
            %         text(xl(1)-diff(xl)*1.05, yl(1)-diff(yl)*0.9, 'b', ...
            %             'fontsize', 12, 'fontname', 'helvetica', 'fontweight', 'bold');
            %         text(xl(1)+diff(xl)*0.7, yl(1)+diff(yl)*1.1, 'Delay', ...
            %             'fontsize', 6, 'fontname', 'helvetica','HorizontalAlignment','Center');
        end
        
        %% Cluster Pure L vs Pure R PSTH
        axes('position',[position_x(1)+horizontal_distance*(mod(plot_counter,columns2plot)), position_y(floor(plot_counter/columns2plot)+1), panel_width, panel_height]);
        flag_xlabel=0;
        ylab='Correct'; num=1;
        legend_flag=1;
        [peak_FR] = fn_plotCluster (plot_counter, columns2plot, Param,time2plot, idx2plot, idx_time2plot,  L, R, num, [], flag_xlabel, peak_LR_hit_units,ylab, legend_flag);
        
        axes('position',[position_x(1)+horizontal_distance*(mod(plot_counter,columns2plot)), position_y(floor(plot_counter/columns2plot)+1)-0.1, panel_width, panel_height]);
        flag_xlabel=1;
        ylab='Error'; num=2;
        legend_flag=1;
        [~] = fn_plotCluster (plot_counter, columns2plot, Param,time2plot, idx2plot, idx_time2plot,  L, R, num, [], flag_xlabel, peak_LR_hit_units,ylab, legend_flag);
        
        %     axes('position',[position_x(1)+horizontal_distance*(mod(plot_counter,columns2plot)), position_y(floor(plot_counter/columns2plot)+1)-0.2, panel_width, panel_height]);
        %     flag_xlabel=1;
        %     ylab='No lick'; num=3;
        %     legend_flag=1;
        %     [~] = fn_plotCluster (plot_counter, columns2plot, Param,time2plot, idx2plot, idx_time2plot,  L, R, num, peak_FR,flag_xlabel, peak_LR_hit_units,ylab, legend_flag);
        
        plot_counter = plot_counter +1;
        
    end
    
    
    
    
    
    
    filename = ['clusters_session' num2str(key.session)];
    
    
    if isempty(dir(dir_save_figure))
        mkdir (dir_save_figure)
    end
    figure_name_out=[ dir_save_figure filename];
    eval(['print ', figure_name_out, ' -dtiff -cmyk -r300']);    
%     eval(['print ', figure_name_out, ' -painters -dpdf -cmyk -r200']);
    clf
end

end