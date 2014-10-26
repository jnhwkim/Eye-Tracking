function figurestyle(font_size)

if nargin < 1
    font_size = 13;
end

% Change default axes fonts.
set(0,'DefaultAxesFontName', 'Palatino')
set(0,'DefaultAxesFontSize', font_size)

% Change default text fonts.
set(0,'DefaultTextFontname', 'Palatino')
set(0,'DefaultTextFontSize', font_size)

box off;