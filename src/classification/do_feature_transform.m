function do_feature_transform(dataset, transform, ...
    feature_transform_path, feature_path, ...
    dataset_evaluation_mode, overwrite)
check_path(feature_transform_path);
transform_type = transform.type;
progress(1, 'Collecting data', 0, '');
parfor fold = dataset.folds(dataset_evaluation_mode)
    current_transform_file = ...
        get_feature_transform_filename(fold, feature_transform_path);
    if and(exist(current_transform_file,'file'), ~overwrite)
        continue
    end
    train_items = dataset.train(fold);
    example_cells = cell(1, length(train_items));
    for item_id = 1:length(train_items)
        item = train_items(item_id);
        progress(0, 'Collecting data', ...
            (item_id / length(train_items)), item.file, fold);
        example = load_data(get_feature_filename(item.file, feature_path));
        example_cells{item_id} = example.feat;
    end
    X = [example_cells{:}];
    if strcmp(transform_type, 'boxcox')
        nFeatures = size(X, 1);
        lambdas = nan(nFeatures, 1);
        for feature_index = 1:nFeatures
            [~, lambdas(feature_index)] = boxcox(X(feature_index, :));
        end
    end
    feature_transform = struct('lambdas', lambdas);
    % Save
    save_data(current_transform_file, feature_transform);
end
disp('  ');
end