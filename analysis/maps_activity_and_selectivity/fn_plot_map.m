function fn_plot_map(map,cmp,label,k)

amax=prctile(map(:),99);
amin=prctile(map(:),1);
map_scaled = size(cmp,1)*mat2gray(map,[amin amax]);
colormap(cmp);
imagesc(map_scaled);
title(sprintf('Trial Epoch: %s\n %s',k.trial_epoch_name, label));
