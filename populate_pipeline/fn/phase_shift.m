function im = phase_shift(im,pix);
rows = size(im,1);
cols = size(im,2);
if pix ~=0
    ind = 1:2:rows;
    if pix > 0
        im = [zeros(rows,pix,size(im,3)) im zeros(rows,pix,size(im,3))];
        il = 1:size(im,2)-pix;
        ir = 1+pix:size(im,2);
    elseif pix < 0
        pix = abs(pix);
        im = [zeros(rows,pix,size(im,3)) im zeros(rows,pix,size(im,3))];
        ir = 1:size(im,2)-pix;
        il = 1+pix:size(im,2);
    end    
    im(ind,il,:) = im(ind,ir,:);
else
    im = im;
end

