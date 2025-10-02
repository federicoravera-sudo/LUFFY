function scatterPlot(data, var1, var2)
    x = data.(var1);
    y = data.(var2);
    % Calcolo del coefficiente di correlazione
    R = abs(corr(abs(x), y)); % se vuoi usare x non convertito togli .*2.54
    figure;
    scatter(x.*2.54, y, 'filled');
    xlabel(var1);
    ylabel(var2);
    title(['Scatter plot di ', var1, ' vs ', var2]);
    grid on;
    hold off;


% Visualizzazione in console
disp(['Coefficiente di correlazione tra ', var1, ' e ', var2, ' = ', num2str(R)]);
end
