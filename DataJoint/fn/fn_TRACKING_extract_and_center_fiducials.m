function [fSession,fTrial] = fn_TRACKING_extract_and_center_fiducials (fSession, fTrial, rel_fiducials_session, rel_fiducials_trial, k, num, offset_cam_x, offset_cam_y, reverse_cam_x, reverse_cam_y, camera_num, camera_pixels_to_mm, p_threshold)

%% Session averages
fSession(num).camera = camera_num;
fSession(num).label = k.video_fiducial_name;

fSession(num).x_median=(fetchn(rel_fiducials_session& k,'fiduical_x_median_session') - offset_cam_x) * reverse_cam_x * camera_pixels_to_mm;
fSession(num).x_min=(fetchn(rel_fiducials_session& k,'fiduical_x_min_session') - offset_cam_x) * reverse_cam_x * camera_pixels_to_mm;
fSession(num).x_max=(fetchn(rel_fiducials_session& k,'fiduical_x_max_session') - offset_cam_x) * reverse_cam_x * camera_pixels_to_mm;
if reverse_cam_x==-1
    fSession(num).x_min=(fetchn(rel_fiducials_session& k,'fiduical_x_max_session') - offset_cam_x) * reverse_cam_x * camera_pixels_to_mm;
    fSession(num).x_max=(fetchn(rel_fiducials_session& k,'fiduical_x_min_session') - offset_cam_x) * reverse_cam_x * camera_pixels_to_mm;
end

fSession(num).y_median=(fetchn(rel_fiducials_session& k,'fiduical_y_median_session') - offset_cam_y) * reverse_cam_y * camera_pixels_to_mm;
fSession(num).y_min=(fetchn(rel_fiducials_session& k,'fiduical_y_min_session') - offset_cam_y) * reverse_cam_y * camera_pixels_to_mm;
fSession(num).y_max=(fetchn(rel_fiducials_session& k,'fiduical_y_max_session') - offset_cam_y) * reverse_cam_y * camera_pixels_to_mm;
if reverse_cam_y==-1
    fSession(num).y_min=(fetchn(rel_fiducials_session& k,'fiduical_y_max_session') - offset_cam_y) * reverse_cam_y * camera_pixels_to_mm;
    fSession(num).y_max=(fetchn(rel_fiducials_session& k,'fiduical_y_min_session') - offset_cam_y) * reverse_cam_y * camera_pixels_to_mm;
end
%% Trials
fTrial(num).camera = camera_num;
fTrial(num).label = k.video_fiducial_name;

X=(fetchn(rel_fiducials_trial & k,'fiducial_x')')';
Y=(fetchn(rel_fiducials_trial & k,'fiducial_y')')';
P = (fetchn(rel_fiducials_trial & k,'fiducial_p')')';

for i = 1:1:numel(X)
    p = P{i};
    x = X{i};
    x(p<p_threshold)=NaN;
    y = Y{i};
    y(p<p_threshold)=NaN;
    X{i} = (x - offset_cam_x) * reverse_cam_x * camera_pixels_to_mm;
    Y{i} = (y - offset_cam_y) * reverse_cam_y * camera_pixels_to_mm;
end
fTrial(num).x=X;
fTrial(num).y=Y;
fTrial(num).p=(fetchn(rel_fiducials_trial & k,'fiducial_p')')';

end