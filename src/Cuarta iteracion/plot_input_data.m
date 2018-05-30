function[]  = plot_input_data(data_input, data_output)
    figure(1);
    data_size = size(data_input);
    n_plots = data_size(1) + 1;
    
    for i = 1:n_plots
        subplot(n_plots,1,i);
        if i == 6
            plot(data_output);
        else
            plot(data_input(i,:));
        end
    end
end