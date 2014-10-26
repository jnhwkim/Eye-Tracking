function figuresave( filename )
%FIGURESAVE Save the current figure as a file.
%   Save the current figure as a pdf file for a given filename.

% Print figure to pdf and png files
set(gcf,'PaperPositionMode','auto');
print('-dpdf', sprintf('%s.pdf', filename)); 

end

