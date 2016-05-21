function features = scattering_extraction(y, archs)
%% Truncation
chunk_length = archs{1}.banks{1}.spec.size;
y_length = length(y);
hop_length = chunk_length / 2;
remainder = rem(y_length, hop_length);
truncated_length = y_length - remainder;
y = y(1:truncated_length);
y_length = length(y);

%%
nLayers = length(archs);
S = cell(1, nLayers);
U = cell(1, nLayers);
Y = cell(1, nLayers);

U{1+0} = initialize_U(y, archs{1}.banks{1});

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
S1 = S{1+1}.data((1+end/4):(3*end/4), 2:(end-1), :);
S1 = reshape(S1, size(S1, 1) * size(S1, 2), size(S1, 3));
imagesc(S1.');

%%
J2_time = length(S{1+2}{1,1}.data);
S2_psi = cell(1, J2_time);
for j2_time = 1:J2_time
    tensor = cat(5, S{1+2}{1,1}.data{j2_time}{:});
    tensor = tensor((1+end/4):(3*end/4), 2:(end-1), :, :, :, :);
    tensor = reshape(tensor, ...
        size(tensor, 1) * size(tensor, 2), ...
        size(tensor, 3), size(tensor, 4), size(tensor, 5));
    S2_psi{j2_time} = tensor;
end
end

