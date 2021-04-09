function fn_plot_map2(map,cmp,label,k, ax)

amax=prctile(map(:),99.9);
amin=prctile(map(:),0.1);
map_scaled = size(cmp,1)*mat2gray(map,[amin amax]);
imagesc(map_scaled);
colormap(ax, cmp);
title(sprintf('Trial Epoch: %s\n %s',k.trial_epoch_name, label));
