function do_feature_extraction(files, dataset, feature_path, ...
    feature_params, overwrite)
% Feature extraction
% 
% Parameters
% ----------
% files : cell array
%     file list
% 
% dataset : class
%     dataset class
% 
% feature_path : str
%     path where the features are saved
% 
% params : struct
%     parameter dict
% 
% overwrite : bool
%     overwrite existing feature files
% 
% Returns
% -------
% nothing
% 
% Raises
% -------
% error
%     Audio file not found.
% 
%    

% Check that target path exists, create if not
check_path(feature_path);

progress(1,'Extracting',(0 / length(files)), '');
binaural_augmentation = default(feature_params, 'binaural_augmentation', false);

parfor file_id = 1:length(files)
    disp(file_id);
    audio_filename = files{file_id};
    [raw_path, raw_filename, ext] = fileparts(audio_filename);
    current_feature_file = get_feature_filename(audio_filename, feature_path);

    progress(0,'Extracting',(file_id / length(files)), raw_filename)

    if or(~exist(current_feature_file,'file'),overwrite)
        % Load audio data
        if exist(dataset.relative_to_absolute_path(audio_filename), 'file')
            [y, fs] = load_audio( ...
                dataset.relative_to_absolute_path(audio_filename), ...
                'mono', ~binaural_augmentation, ...
                'target_fs', feature_params.fs);
        else
            error(['Audio file not found [', audio_filename, ']']);                
        end
        
        % Binaural augmentation
        if binaural_augmentation
            n_azimuths = feature_params.n_azimuths;
            y_stereo = y;
            y_azimuths = zeros(size(y_stereo, 1), n_azimuths);
            pans = linspace(0, 1, n_azimuths);
            for azimuth_index = 1:n_azimuths
                pan = pans(azimuth_index);
                y_azimuths(:, azimuth_index) = ...
                    pan * y_stereo(:, 1) + (1-pan) * y_stereo(:, 2);
            end
            y = y_azimuths;
        end

        % Extract features
        if isfield(feature_params, 'scattering')
            feature_data = ...
                scattering_extraction(y, feature_params.scattering.archs);
        else
            feature_data = feature_extraction(y, fs, ...
              'statistics', true, ...
              'include_mfcc0', feature_params.include_mfcc0, ...
              'include_delta', feature_params.include_delta, ...
              'include_acceleration', feature_params.include_acceleration, ...
              'mfcc_params', feature_params.mfcc, ...
              'delta_params', feature_params.mfcc_delta, ...
              'acceleration_params', feature_params.mfcc_acceleration); 
        end

        % Save
        save_data(current_feature_file, feature_data)
    end
end
disp('  ');
end