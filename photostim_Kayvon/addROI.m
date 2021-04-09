function addROI(pos,fluor,pixelList,plane);
global dat
topLeft = dat.rect;
dim = dat.dim;
pixPerUnits = dim./range(topLeft);
POS = pos;
% POS(2) = 512 - POS(2);
if ~exist('plane')
  plane = 1;
end
centerXY = (topLeft(1,:) + POS./pixPerUnits);
if ~isfield(dat,'roi');
    dat.roi(1).centroid = pos;
    dat.roi(1).centerXY = centerXY;
    dat.roi(1).plane    = plane;
    if exist('pixelList')
        dat.roi(1).pixelList = pixelList;
        [row col] = ind2sub(dat.dim,pixelList);
        dat.roi(1).scalingXY = [range(row) range(col)]./dat.dim.*range(dat.rect);
    end
    if ~isempty(fluor);
        dat.roi(1).intensityR = cellfun(@(x) x',fluor{1},'uniformoutput',0);
        dat.roi(1).intensityL = cellfun(@(x) x',fluor{2},'uniformoutput',0);
    end
else
    if isfield(dat,'deletedCell')
        num = dat.deletedCell-1;
        dat = rmfield(dat,'deletedCell');
        set(gcf,'Pointer','arrow');
    else
        num = length(dat.roi);
    end
    dat.roi(num + 1).centroid = pos;
    dat.roi(num + 1).centerXY = centerXY;
    dat.roi(num + 1).plane    = plane;
    if exist('pixelList')
        dat.roi(num + 1).pixelList = pixelList;
        [row col] = ind2sub(dat.dim,pixelList);
        dat.roi(num + 1).scalingXY = [range(row) range(col)]./dat.dim.*range(dat.rect);
    end
    if ~isempty(fluor);
        dat.roi(num + 1).intensityR = cellfun(@(x) x',fluor{1},'uniformoutput',0);
        dat.roi(num + 1).intensityL = cellfun(@(x) x',fluor{2},'uniformoutput',0);
    end
end