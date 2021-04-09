function [cmp] = fn_plot_map4(map, label, k, colorbar_label)

maxv=prctile(map(:),99);
minv=prctile(map(:),1);

%rescaling
map(map>maxv)=maxv;
map(map<minv)=minv;

imagesc(map);
cmp = bluewhitered(256); % 256 element colormap

% white_index = find(cmp(:,1)==1 & cmp(:,2)==1 & cmp(:,3)==1, 1);
% histogram(map(:))

% amax=prctile(map(:),99.9);
% amin=prctile(map(:),0.1);
%

title(sprintf('Trial Epoch: %s\n %s',k.trial_epoch_name, label),'FontSize',12);
axis equal;
axis tight;
axis off;
box off;
cbar=colorbar('southoutside');

if exist('colorbar_label')
    cbar.Label.String =   colorbar_label;
else
    cbar.Label.String = colorbar_label;
end
set(cbar,'Ticks',[cbar.Limits(1) 0 cbar.Limits(2)],...
    'TickLabels',{'Right','0','Left'},'FontSize',12)