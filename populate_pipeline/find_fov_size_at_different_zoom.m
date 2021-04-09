load('Z:\users\Arseny\Projects\Learning\imaging2p\code\populate_pipeline\fov_size_at_different_zoom.mat')
zoom=1.6
xy=[interp1(imageSize(:,1),imageSize(:,2),zoom), interp1(imageSize(:,1),imageSize(:,3), zoom)]