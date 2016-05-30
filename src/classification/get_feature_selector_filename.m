function filename = get_feature_selector_filename(fold, path, extension)
if nargin < 3
    extension = 'mat';
end
filename = fullfile(path, ['fold', num2str(fold), '.', extension]);
end