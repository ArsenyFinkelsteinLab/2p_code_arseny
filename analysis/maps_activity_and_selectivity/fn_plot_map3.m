function cmp = fn_plot_map3(map, label, k, colorbar_label)

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

title(sprintf('Trial Epoch: %s\n %s',k.trial_epoch_name, label));
axis equal;
axis tight;
axis off;
box off;
c=colorbar('southoutside');

if exist('colorbar_label')
    c.Label.String =   colorbar_label;
else
    c.Label.String = '\DeltaF/F';
end
