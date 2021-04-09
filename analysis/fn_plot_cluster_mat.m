function []=fn_plot_cluster_mat(mat)

imagesc(mat,[0,1]);
colormap(jet);
% if size (mat,1)<500
%     set(gca,'xtick',[1,100:100:size(mat,1)],'ytick',100:100:size(mat,2))
% elseif size(mat,1)>500 && size (mat,1)<=1000
%     set(gca,'xtick',[1,200:200:size(mat,1)],'ytick',200:200:size(mat,2))
% elseif size(mat,1)>1000
%     set(gca,'xtick',[1,500:500:size(mat,1)],'ytick',500:500:size(mat,2))
% end
xlabel('Clustered','FontSize',8)
ylabel('Clustered','FontSize',8)
title('Pairwise distance','FontSize',8);
  axis equal
        axis tight;
%     colorbar;
