function cmp = fn_plot_photostim_map(map)
% map=map*(-1);
% map(~pixel_idx,~pixel_idx)=0;
% maxv=prctile(map(:),99.999);
% minv=prctile(map(:),0.001);

maxv=prctile(map(:),99.9);
minv=prctile(map(:),0.0005);

% maxv=prctile(map(:),99);
% minv=prctile(map(:),0.0005);

%rescaling
map(map>maxv)=maxv;
map(map<minv)=minv;

imagesc(map);
cmp = (bluewhitered(256)); % 256 element colormap

% white_index = find(cmp(:,1)==1 & cmp(:,2)==1 & cmp(:,3)==1, 1);
% histogram(map(:))

% amax=prctile(map(:),99.9);
% amin=prctile(map(:),0.1);
% 

% title(sprintf('Trial Epoch: %s\n %s',k.trial_epoch_name, label));
axis equal;
axis tight;
axis off;
box off;
c=colorbar('southoutside');

if exist('colorbar_label')
    c.Label.String =   colorbar_label;
else
    c.Label.String = '\DeltaF photostim';
end
