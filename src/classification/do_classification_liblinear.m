function result = do_classification_liblinear(feature_data, model_container)
    % LIBLINEAR classification for give feature matrix
    %
    % model container format (struct):
    %   model.normalizer = normalizer_class;
    %   model.models = containers.Map();
    %   model.models('all') = model_struct;
    %
    % Parameters
    % ----------
    % feature_data : matrix [shape=(feature vector length, t)]
    %     feature matrix
    %
    % model_container : struct
    %     model container
    %
    % Returns
    % -------
    % result : str
    %     classification result as scene label
    %

    all_models = model_container.models('all');

    labels = predict( ...
        ones(size(feature_data, 2), 1), sparse(feature_data)', ...
        all_models.liblinear_model, '-q');

    n = hist(labels, 1:numel(all_models.classes));
    [~, result_id] = max(n);

    result = all_models.classes{result_id};
end
