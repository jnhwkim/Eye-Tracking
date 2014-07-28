%% Read files
filenames = dir('data/pororo_s03p0*.tsv');
seconds = 2000;
threshold = 3;
unit = 30;

[period_table, fixations] = get_long(filenames, seconds, threshold, unit);
show_period(fixations, seconds, period_table, unit);
