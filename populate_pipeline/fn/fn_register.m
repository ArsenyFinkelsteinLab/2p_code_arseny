function [im] = fn_register(im ,template,phase,decimationFactor)
        dim = size(template);%[header.SI.hRoiManager.linesPerFrame header.SI.hRoiManager.pixelsPerLine];
%         im = (phase_shift(im,phase));
%         im = im(:,1+phase:phase+dim(2),:);
        %         im = squeeze(im(:,:,1,:));
        im = shiftIm(im,template,decimationFactor);
end


