function PLOT_CorrPairwiseDistanceVoxels()
close all;

dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\POP\corr_distance_pop\'];


% key.subject_id=463190;
rel_data = POP.CorrPairwiseDistanceSVDVoxels;
num_svd_components_removed_vector = [0, 1, 10, 100, 500];

threshold_for_event_vector = unique([fetchn(rel_data, 'threshold_for_event')]);
threshold_for_event_vector=[0];
lateral_distance_bins = fetch1(rel_data,'lateral_distance_bins','LIMIT 1');
x=lateral_distance_bins(1:end-1)+diff(lateral_distance_bins)/2;

figure
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
set(gcf,'color',[1 1 1]);

horizontal_dist=0.5;
vertical_dist=0.15;

panel_width1=0.4;
panel_height1=0.2;

position_x1(1)=0.1;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;
position_x1(end+1)=position_x1(end)+horizontal_dist;

position_y1(1)=0.75;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;
position_y1(end+1)=position_y1(end)-vertical_dist;



colors=viridis(numel(num_svd_components_removed_vector)+2);

min_x=0; max_x=1000;
% min_x=3; max_x=8;

key.session_epoch_type= 'behav_only';
for i_c=1:1:numel(num_svd_components_removed_vector)
    key.num_svd_components_removed=num_svd_components_removed_vector(i_c);
    
    for i_th=1:1:numel(threshold_for_event_vector)
        key.threshold_for_event = threshold_for_event_vector(i_th);
        D=fetch(rel_data&key,'*');
        for i=1:1:numel(D)
            idx_same_bins(i) = sum(D(i).axial_distance_bins==35);
            axial_distance_bins_size(i)=numel(D(i).axial_distance_bins);
        end
        
        idx_same_bins=find(idx_same_bins);
        [max_axial_distance,idxidx]=max(axial_distance_bins_size(idx_same_bins));
        xx=D(idxidx). axial_distance_bins;
        
        map=zeros(numel(lateral_distance_bins)-1,max_axial_distance);
        for i=1:1:numel(idx_same_bins)
            current_map = D(i).distance_corr_all;
            map(:,1:size(current_map,2))=[map(:,1:size(current_map,2)) + current_map];
            %             map(size(current_map) = map
        end
        max_axials=axial_distance_bins_size(idx_same_bins);
        for i=1:1:max_axials
            divide_factor (i) = sum((axial_distance_bins_size(idx_same_bins)>=i));
        end
        map=map./divide_factor;
        
        
        ax(i_c)=axes('position',[position_x1(1), position_y1(i_c), panel_width1, panel_height1]);
        %         xx=D.axial_distance_bins(1:end);
        %         map=D.distance_corr_all;
        maxv=prctile(map(:),99);
        minv=min([prctile(map(:),0),0]);
        %rescaling
        map(map>maxv)=maxv;
        map(map<minv)=minv;
        imagesc(x,xx,map')
                cmp = bluewhitered(512); % 256 element colormap
        axis tight
        axis equal
        title(sprintf('# Dimensions projected out = %d',num_svd_components_removed_vector(i_c)));
        if i_c==numel(num_svd_components_removed_vector)
            xlabel([sprintf('Lateral Distance ') '(\mum)']);
            ylabel([sprintf('Axial Distance ') '(\mum)']);
        end
        colormap(ax(i_c),cmp);
        colorbar;
        %         ax2=axes('position',[position_x1(1), position_y1(2), panel_width1, panel_height1]);
        %         xx=D.axial_distance_bins(1:end);
        %         map=D.distance_corr_positive;
        %         maxv=prctile(map(:),99);
        %         minv=min([prctile(map(:),0.05),0]);
        %         rescaling
        %         map(map>maxv)=maxv;
        %         map(map<minv)=minv;
        %         imagesc(map);
        %         cmp = bluewhitered(256); % 256 element colormap
        %         colormap(ax2,cmp)
        %         imagesc(x,xx,map')
        %         axis tight
        %         axis equal
        %         xlabel('Lateral distance (um)');
        %         ylabel('Axial \nDistance(um)');
        %                 colormap(ax2,cmp)
        
        %         ax2=axes('position',[position_x1(2), position_y1(1), panel_width1, panel_height1]);
        %         xx=D.axial_distance_bins(1:end);
        %         map=D.distance_corr_negative;
        %         maxv=prctile(map(:),99);
        %         minv=min([prctile(map(:),0.05),0]);
        %         %rescaling
        % %         map(map>maxv)=maxv;
        % %         map(map<minv)=minv;
        %         imagesc(map);
        % %         cmp = bluewhitered(256); % 256 element colormap
        % cmp=jet;
        %         colormap(ax2,cmp)
        %         imagesc(x,xx,map')
        %         axis tight
        %         axis equal
        %         xlabel('Lateral distance (um)');
        %         ylabel('Axial \nDistance(um)');
        %         colormap(ax2,cmp)
        
        
        
    end
end
a=1
% colors=jet(numel(num_svd_components_removed_vector)+2);
%
% key.session_epoch_type= 'spont_only';
% for i_th=1:1:numel(threshold_for_event_vector)
%     key.threshold_for_event = threshold_for_event_vector(i_th);
%     D=fetch(rel_data&key,'*');
%
%
%     subplot(numel(threshold_for_event_vector),3,((i_th-1)*3+1))
%     hold on
%     if i_th==1 && i_c==1
%         plot([xx(1),xx(end)],[0,0],'-k');
%     end
%     y = cell2mat({D.distance_corr_all}');
%     ymean=nanmean(y,1);
%     ystem=nanstd(y,1)/sqrt(size(y,1));
%     shadedErrorBar(xx,ymean,ystem,'lineprops',{'-','Color',colors(i_c,:)})
%     %                 ylim([0,max(ymean+ystem)])
%     ylabel(sprintf('Pairwise corr.\n (all)'));
%     xlim([min_x max_x]);
%     xlabel('Lateral Distance (\mum)');
%
%     %     if i_th==1
%     %         title(sprintf('anm%d session %d %s\n%s %d \n threshold =%.2f rois=%d', key.subject_id,key.session,session_date,session_epoch_label, key.session_epoch_number,  threshold_for_event_vector(i_th), key.num_of_rois));
%     %     else
%     %         title(sprintf('Threshold for event = %.2f rois=%d',threshold_for_event_vector(i_th), key.num_of_rois));
%     %     end
%     subplot(numel(threshold_for_event_vector),3,((i_th-1)*3+2))
%     hold on
%     y = cell2mat({D.distance_corr_positive}');
%     ymean=nanmean(y,1);
%     ystem=nanstd(y,1)/sqrt(size(y,1));
%     shadedErrorBar(xx,ymean,ystem,'lineprops',{'-','Color',colors(i_c,:)})
%     %                 ylim([0,max(y1mean+y1stem)])
%     ylabel(sprintf('Pairwise corr.\n (positive)'));
%     xlim([min_x max_x]);
%     xlabel('Lateral Distance (\mum)');
%
%     subplot(numel(threshold_for_event_vector),3,((i_th-1)*3+3))
%     y = cell2mat({D.distance_corr_negative}');
%     ymean=nanmean(y,1);
%     ystem=nanstd(y,1)/sqrt(size(y,1));
%     shadedErrorBar(xx,ymean,ystem,'lineprops',{'-','Color',colors(i_c,:)})
%     %             ylim([0,max(y2mean+y2stem)])
%     ylabel(sprintf('Pairwise corr.\n (negative)'));
%     xlim([min_x max_x]);
%     xlabel('Lateral Distance (\mum)');
%
% end
% a=1;
