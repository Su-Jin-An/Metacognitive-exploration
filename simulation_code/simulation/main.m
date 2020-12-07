%% Excuting All functions (Preprocess - KWIK - RPE - Geodesic)
subject_list=[1:6 8:44];

% KWIK with absolute value
KWIK_absVal(subject_list);

% Calculate geodesic distance
calculate_Geodesic(subject_list);

% find Geodesic version of sampling type
findMedian_Udist_Geodesic(subject_list);

% Classify Early stage, Middle stage, Late stage 
early_middle_late(subject_list); 
early_late(subject_list); 
