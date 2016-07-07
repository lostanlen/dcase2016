function do_system_evaluation(dataset, result_path, dataset_evaluation_mode)
    % System evaluation. Testing outputs are collected and evaluated. Evaluation results are printed.
    % 
    % Parameters
    % ----------
    % dataset : class
    %     dataset class
    % 
    % result_path : str
    %     path where the results are saved.
    % 
    % dataset_evaluation_mode : str ['folds', 'full']
    %     evaluation mode, 'full' all material available is considered to belong to one fold.
    % 
    % Returns
    % -------
    % nothing
    % 
    % Raises
    % -------
    % error
    %     Result file not found
    % 

    dcase2016_scene_metric = DCASE2016_SceneClassification_Metrics(dataset.scene_labels());

    results_fold = [];
    progress(1,'Collecting results',0,'');

    for fold=dataset.folds(dataset_evaluation_mode)
        dcase2016_scene_metric_fold = DCASE2016_SceneClassification_Metrics(dataset.scene_labels());
        results = [];
        result_filename = get_result_filename(fold, result_path);
        if exist(result_filename,'file')
            fid = fopen(result_filename, 'r');
            C = textscan(fid, '%s%s', 'delimiter', '\t');
            fclose(fid);             
        else
            error(['Result file not found [', result_filename, ']']);
        end
        
        for i=1:length(C{1})
            results = [results; {C{1}{i} C{2}{i}}];
        end
        y_true = [];
        y_pred = [];
        for result_id=1:length(results)
            progress(0, 'Collecting results', (result_id / length(results)), '', fold);
            y_true = [y_true; {dataset.file_meta(results{result_id,1}).scene_label}];
            y_pred = [y_pred; {results{result_id,2}}];
        end
        dcase2016_scene_metric.evaluate(y_pred, y_true);
        dcase2016_scene_metric_fold.evaluate(y_pred, y_true);
        results_fold = [results_fold; dcase2016_scene_metric_fold.results()];
    end
    disp('  ');

    results = dcase2016_scene_metric.results();

    fprintf('  File-wise evaluation, over %d folds\n', dataset.fold_count());

    separator = '     =====================+======+======+===========+';
    fold_labels = '';
    if dataset.fold_count() > 1
        separator = [separator,'  +'];
        for fold=dataset.folds(dataset_evaluation_mode)
            fold_labels = [fold_labels, sprintf(' %-8s |', ['fold',num2str(fold)])];
            separator = [separator,'==========+'];
        end
    end

    fprintf(['     %-20s | %-4s : %-4s | %-8s  |  |',fold_labels,'\n'], 'Scene label', 'Nref', 'Nsys', 'Accuracy');
    fprintf([separator,'\n']);
    labels = results.class_wise_accuracy.keys;
    csv_output = '';
    for label_id=1:length(labels)
        fold_values = '';
        csv_output = [csv_output sprintf('"%s", ', labels{label_id})];
        if dataset.fold_count() > 1
            for fold=dataset.folds(dataset_evaluation_mode)
                fold_values = [fold_values, sprintf(' %5.1f %%  |', results_fold(fold).class_wise_accuracy(labels{label_id}) * 100)];
                csv_output = [csv_output sprintf('%f, ', results_fold(fold).class_wise_accuracy(labels{label_id}))];
            end
        end
        values = sprintf('     %-20s | %4d : %4d | %5.1f %%   |  |', labels{label_id},...
                                                                     results.class_wise_data(labels{label_id}).Nref,...
                                                                     results.class_wise_data(labels{label_id}).Nsys,...
                                                                     results.class_wise_accuracy(labels{label_id})*100 );
        csv_output = [csv_output sprintf('%f\n', results.class_wise_accuracy(labels{label_id}))];

        disp([values, fold_values]);
    end
    fprintf([separator,'\n']);
    fold_values = '';
    if dataset.fold_count() > 1
        for fold=dataset.folds(dataset_evaluation_mode)
            fold_values = [fold_values, sprintf(' %5.1f %%  |', results_fold(fold).overall_accuracy * 100)];
        end
    end

    values = sprintf('     %-20s | %4d : %4d | %5.1f %%   |  |', 'Overall performance',...
                                                                 results.Nref,...
                                                                 results.Nsys,...
                                                                 results.overall_accuracy * 100);
    disp([values, fold_values]);

    f = fopen('evaluation.csv', 'w');
    fwrite(f, csv_output);
    fclose(f);
end
