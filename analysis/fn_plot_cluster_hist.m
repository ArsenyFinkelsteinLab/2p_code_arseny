function []=fn_plot_cluster_hist(cl_id, mat, order, data)
hold on;

[y,bins]=hist(cl_id,[min(cl_id):max(cl_id)]);
bar(bins,y*(size(data,1)/max(y)),'FaceColor','none');


% Labels for cluster identity on distance matrix.
n_clust_after_merging = numel(unique(cl_id));
col2plot = hsv(n_clust_after_merging);
col2plot_dark = col2plot./2;
for i = 1:n_clust_after_merging
    ind_plot = find(cl_id(order)==i);
    plot(i*ones(1,length(ind_plot)),size(data,1)-ind_plot,'.','color',col2plot(i,:)); hold on
end
set(gca,'xtick',[],'ytick',[]);
xlim([-1 n_clust_after_merging+1]);
ylim([0 size(data,1)]);
%     axes('position',[position_x1(1+subplot_shift)+0.15 position_y1(2) panel_width1/2 panel_height1]);
axis off;
box off;



