function do_feature_extraction(files, dataset, feature_path, params, overwrite)
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

    progress(1,'Extracting',(0 / length(files)),'');
    for file_id = 1:length(files)
        audio_filename = files{file_id};
        [raw_path, raw_filename, ext] = fileparts(audio_filename);
        current_feature_file = get_feature_filename(audio_filename,feature_path);
        
        progress(0,'Extracting',(file_id / length(files)),raw_filename)
        
        if or(~exist(current_feature_file,'file'),overwrite)
            % Load audio data
            if exist(dataset.relative_to_absolute_path(audio_filename),'file')
                [y, fs] = load_audio(dataset.relative_to_absolute_path(audio_filename), 'mono', true, 'target_fs', params.fs);
            else
                error(['Audio file not found [',audio_filename,']']);                
            end
            
            % Extract features
            feature_data = feature_extraction(y,fs,...
                                              'statistics',true,...
                                              'include_mfcc0',params.include_mfcc0,...
                                              'include_delta',params.include_delta,...
                                              'include_acceleration',params.include_acceleration,...
                                              'mfcc_params',params.mfcc,...
                                              'delta_params',params.mfcc_delta,...
                                              'acceleration_params', params.mfcc_acceleration);                
                                          
            % Save
            save_data(current_feature_file, feature_data)
        end
    end
    disp('  ');
end