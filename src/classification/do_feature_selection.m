function do_feature_selection(dataset, selection, feature_path, ...
    dataset_evaluation_mode, overwrite)
criterion = selection.criterion;
epsilon = selection.epsilon;
progress(1, 'Collecting data', 0, '');
parfor fold=dataset.folds(dataset_evaluation_mode)
    example_cells = cell(1, length(train_items));
    for item_id = 1:length(train_items)
        item = train_items(item_id);
        progress(0, 'Collecting data', ...
            (item_id / length(train_items)), item.file, fold);
        example = load_data(get_feature_filename(item.file, feature_path));
        example_cells{item_id} = example.feat;
    end
    X = [example_cells{:}];
    if strcmp(criterion, 'energy')
        energies = sum(X.*X, 2);
        energies = energies / sum(energies);
        [sorted_energies, sorting_indices] = sort(energies);
        cumulative_energies = cumsum(sorted_energies);
        start = find(cumulative_energies > epsilon, 1);
        feature_indices = sorting_indices(end:-1:start);
    end
    feature_selector = struct('indices', feature_indices);
    % Save
    save_data(current_normalizer_file, feature_indices);
end
disp('  ');
end

