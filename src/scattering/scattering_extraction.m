function features = scattering_extraction(y, archs)
%% Truncation
original_length = 30 * 44100;
truncated_length = 5 * 2^18;
start = 1 + (original_length - truncated_length) / 2;
stop = original_length - start + 1;
y = y(start:stop, :);
nAzimuths = size(y, 2);
if nAzimuths > 1
    y = reshape(y, size(y, 1), 1, size(y, 2));
end

%% Chunking
chunk_length = 2^19;
hop_length = 2^18;
chunk_range = 1:chunk_length;
chunks = cat(2, ...
    y(0*hop_length + chunk_range, :, :), ...
    y(1*hop_length + chunk_range, :, :), ...
    y(2*hop_length + chunk_range, :, :), ...
    y(3*hop_length + chunk_range, :, :));
nChunks = 4;
chunks = reshape(chunks, size(chunks, 1), nChunks * nAzimuths);

%%
nLayers = length(archs);
S = cell(1, nLayers);
U = cell(1, nLayers);
Y = cell(1, nLayers);

U{1+0} = initialize_U(chunks, archs{1}.banks{1});

%% Propagation cascade
for layer = 1:nLayers
    arch = archs{layer};
    previous_layer = layer - 1;
    % Scatter iteratively layer U to get sub-layers Y
    if isfield(arch, 'banks')
        Y{layer} = U_to_Y(U{1+previous_layer}, arch.banks);
    else
        Y{layer} = U(1+previous_layer);
    end
    
    % Apply nonlinearity to last sub-layer Y to get layer U
    if isfield(arch, 'nonlinearity') 
        U{1+layer} = Y_to_U(Y{layer}{end}, arch.nonlinearity);
    end
    
    % Blur/pool first layer Y to get layer S
    if isfield(arch, 'invariants')
        S{1+previous_layer} = Y_to_S(Y{layer}, arch);
    end
end

%%
S1 = S{1+1}.data((1+end/4):(3*end/4), :, :);
S1 = reshape(S1, size(S1, 1) * nChunks, nAzimuths, size(S1, 3));
S1 = permute(S1, [3, 1, 4, 2]);

%%
if iscell(S{1+2})
else
    [nLambda1s, nFrames, ~] = size(S1);
    nLambda2s = length(S{1+2}.data);
    scattergram = cat(3, S1, zeros(nLambda1s, nFrames, nLambda2s, nAzimuths));
    feat = S1(:, :, 1, floor(end/2));
    for lambda2_index = 1:nLambda2s
        band = S{1+2}.data{lambda2_index}((1+end/4):(3*end/4), :, :);
        band = reshape(band, size(band, 1) * nChunks, nAzimuths, size(band, 3));
        band = permute(band, [3, 1, 4, 2]);
        feat = cat(1, feat, band(:, :, floor(end/2)));
        scattergram(1:size(band,1), :, end + 1 - lambda2_index, :) = band;
    end
end

%%
stat = struct( ...
    'mean', mean(feature_matrix,2), ...
    'std', std(feature_matrix,0,2), ...
    'N', size(feature_matrix,2), ...
    'S1', sum(feature_matrix,2), ...
    'S2',sum(feature_matrix.^2,2));

scattergram_stat = struct( ...
    'mean', mean(mean(mean(scattergram), 2), 4), ...
    'std', std(std(std(scattergram), 0, 2), 0, 4));

features = struct( ...
    'feat', feat, ...
    'stat', stat, ...
    'scattergram', scattergram, ...
    'scattergram_stat', scattergram_stat);

end

