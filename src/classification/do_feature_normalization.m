function do_feature_normalization(dataset, feature_normalizer_path, ...
    feature_path, dataset_evaluation_mode, overwrite)
    % Feature normalization
    %
    % Calculated normalization factors for each evaluation fold based on the training material available.
    % 
    % Parameters
    % ----------
    % dataset : class
    %     dataset class
    %
    % feature_normalizer_path : str
    %     path where the feature normalizers are saved.
    % 
    % feature_path : str
    %     path where the features are saved.
    %
    % dataset_evaluation_mode : str ['folds', 'full']
    %     evaluation mode, 'full' all material available is considered to belong to one fold.
    %
    % overwrite : bool
    %     overwrite existing normalizers
    % 
    % Returns
    % -------
    % nothing
    % 
    % Raises
    % -------
    % error
    %     Features not found.
    %

    % Check that target path exists, create if not
    check_path(feature_normalizer_path);
    progress(1,'Collecting data',0,'');
    parfor fold=dataset.folds(dataset_evaluation_mode)
        current_normalizer_file = ...
            get_feature_normalizer_filename(fold, feature_normalizer_path);
        if or(~exist(current_normalizer_file,'file'),overwrite)
            % Initialize statistics            
            file_count = length(dataset.train(fold));
            normalizer = FeatureNormalizer();
            train_items = dataset.train(fold);
            
            for item_id=1:length(train_items)
                item = train_items(item_id);
                progress(0, 'Collecting data', ...
                    (item_id / length(train_items)), item.file, fold);
                
                % Load features
                if exist(get_feature_filename(item.file, feature_path), 'file')
                    feature_data = ...
                        load_data(get_feature_filename(item.file, feature_path));
                    if isfield(feature_data, 'stat')
                        % MFCC branch
                        feature_data = feature_data.stat;
                    else
                        % Scattering branch
                        feature_matrix = permute(feature_data, [3, 2, 1, 4]);
                        feature_matrix = feature_matrix(:, :, :);
                        feature_data = struct( ...
                             'mean', mean(feature_matrix, 3),...
                             'std',std(feature_matrix,0, 3),...
                             'N',size(feature_matrix, 3),...
                             'S1',sum(feature_matrix, 3),...
                             'S2',sum(feature_matrix.^2, 3));
                    end
                else
                    error(['Features not found [', item.file, ']']);
                end

                % Accumulate statistics
                normalizer.accumulate(feature_data);
            end

            % Calculate normalization factors
            normalizer.finalize();     

            % Save
            save_data(current_normalizer_file, normalizer);
        end
    end
    disp('  ');
end