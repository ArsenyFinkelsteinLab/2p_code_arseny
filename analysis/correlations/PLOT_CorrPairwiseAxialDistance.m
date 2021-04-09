function PLOT_CorrPairwiseAxialDistance()
close all;
figure
dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
dir_current_fig = [dir_base  '\POP\corr_distance_pop\'];


% key.subject_id=464725;
rel_data = POP.CorrPairwiseDistanceSVDVolumetric;
num_svd_components_removed_vector = [0, 1, 10, 100, 500];

threshold_for_event_vector = unique([fetchn(rel_data, 'threshold_for_event')]);
threshold_for_event_vector=threshold_for_event_vector(1:1:end-1);
column_radius_vector = fetch1(rel_data,'column_radius_vector','LIMIT 1');






colors=fake_parula(numel(num_svd_components_removed_vector)+2);

min_x=0; max_x=200
% min_x=3; max_x=8;

key.session_epoch_type= 'behav_only';
for i_c=1:1:numel(num_svd_components_removed_vector)
    key.num_svd_components_removed=num_svd_components_removed_vector(i_c);

    for i_th=1:1:numel(threshold_for_event_vector)
        key.threshold_for_event = threshold_for_event_vector(i_th);
        D=fetch(rel_data&key,'*');
        
x=D(2).axial_distance_bins(1:end-1);
mm=D(2).column_distance_corr_all;
mm(1,1)=NaN;
imagesc(x,column_radius_vector,mm)
axis equal
%         subplot(numel(threshold_for_event_vector),3,((i_th-1)*3+1))
%         hold on
%         if i_th==1 && i_c==1
%         plot([x(1),x(end)],[0,0],'-k');
%         end
%         y = cell2mat({D.distance_corr_all}');
%         ymean=nanmean(y,1);
%         ystem=nanstd(y,1)/sqrt(size(y,1));
%         shadedErrorBar(x,ymean,ystem,'lineprops',{'-','Color',colors(i_c,:)})
%         %                 ylim([0,max(ymean+ystem)])
%         ylabel(sprintf('Pairwise corr.\n (all)'));
%         xlim([min_x max_x]);
%         xlabel('Lateral Distance (\mum)');
%         %     if i_th==1
%         %         title(sprintf('anm%d session %d %s\n%s %d \n threshold =%.2f rois=%d', key.subject_id,key.session,session_date,session_epoch_label, key.session_epoch_number,  threshold_for_event_vector(i_th), key.num_of_rois));
%         %     else
%         %         title(sprintf('Threshold for event = %.2f rois=%d',threshold_for_event_vector(i_th), key.num_of_rois));
%         %     end
%         
%                subplot(numel(threshold_for_event_vector),3,((i_th-1)*3+2))
%                mmm=zeros(size(D(1).corr_histogram_per_distance));
%                for i=1:1:numel(D)
%                mmm=[mmm + D(i).corr_histogram_per_distance./max(D(i).corr_histogram_per_distance,[],2)];
%                end
%                mmm=mmm./numel(D)
%         hold on 
%         imagesc(x,xh,mmm')
%         
% %         subplot(numel(threshold_for_event_vector),3,((i_th-1)*3+2))
%         hold on
%         y = cell2mat({D.distance_corr_positive}');
%         ymean=nanmean(y,1);
%         ystem=nanstd(y,1)/sqrt(size(y,1));
%         shadedErrorBar(x,ymean,ystem,'lineprops',{'-','Color',colors(i_c,:)})
%         %                 ylim([0,max(y1mean+y1stem)])
%         ylabel(sprintf('Pairwise corr.\n (positive)'));
%         xlim([min_x max_x]);
%         xlabel('Lateral Distance (\mum)');
% %         
% %         subplot(numel(threshold_for_event_vector),3,((i_th-1)*3+3))
%         y = cell2mat({D.distance_corr_negative}');
%         ymean=nanmean(y,1);
%         ystem=nanstd(y,1)/sqrt(size(y,1));
%         shadedErrorBar(x,ymean,ystem,'lineprops',{'-','Color',colors(i_c,:)})
%         %             ylim([0,max(y2mean+y2stem)])
%         ylabel(sprintf('Pairwise corr.\n (negative)'));
%         xlim([min_x max_x]);
%         xlabel('Lateral Distance (\mum)');
%         ylim([-0.1,0.1])
    end
end

colors=jet(numel(num_svd_components_removed_vector)+2);

key.session_epoch_type= 'spont_only';
for i_th=1:1:numel(threshold_for_event_vector)
    key.threshold_for_event = threshold_for_event_vector(i_th);
    D=fetch(rel_data&key,'*');
    
    
    subplot(numel(threshold_for_event_vector),3,((i_th-1)*3+1))
    hold on
        if i_th==1 && i_c==1
        plot([x(1),x(end)],[0,0],'-k');
        end
        y = cell2mat({D.distance_corr_all}');
    ymean=nanmean(y,1);
    ystem=nanstd(y,1)/sqrt(size(y,1));
        shadedErrorBar(x,ymean,ystem,'lineprops',{'-','Color',colors(i_c,:)})
    %                 ylim([0,max(ymean+ystem)])
    ylabel(sprintf('Pairwise corr.\n (all)'));
    xlim([min_x max_x]);
    xlabel('Lateral Distance (\mum)');
    
    %     if i_th==1
    %         title(sprintf('anm%d session %d %s\n%s %d \n threshold =%.2f rois=%d', key.subject_id,key.session,session_date,session_epoch_label, key.session_epoch_number,  threshold_for_event_vector(i_th), key.num_of_rois));
    %     else
    %         title(sprintf('Threshold for event = %.2f rois=%d',threshold_for_event_vector(i_th), key.num_of_rois));
    %     end
    subplot(numel(threshold_for_event_vector),3,((i_th-1)*3+2))
    hold on
    y = cell2mat({D.distance_corr_positive}');
    ymean=nanmean(y,1);
    ystem=nanstd(y,1)/sqrt(size(y,1));
        shadedErrorBar(x,ymean,ystem,'lineprops',{'-','Color',colors(i_c,:)})
    %                 ylim([0,max(y1mean+y1stem)])
    ylabel(sprintf('Pairwise corr.\n (positive)'));
    xlim([min_x max_x]);
    xlabel('Lateral Distance (\mum)');
    
    subplot(numel(threshold_for_event_vector),3,((i_th-1)*3+3))
    y = cell2mat({D.distance_corr_negative}');
    ymean=nanmean(y,1);
    ystem=nanstd(y,1)/sqrt(size(y,1));
        shadedErrorBar(x,ymean,ystem,'lineprops',{'-','Color',colors(i_c,:)})
    %             ylim([0,max(y2mean+y2stem)])
    ylabel(sprintf('Pairwise corr.\n (negative)'));
    xlim([min_x max_x]);
    xlabel('Lateral Distance (\mum)');
    
end
a=1;
