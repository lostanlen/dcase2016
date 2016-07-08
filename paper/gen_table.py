import csv
import numpy as np

def main():
	fold_ct = 4

	eval_scattering = read_eval_csv('eval_scattering.csv', fold_ct)
	eval_baseline = read_eval_csv('eval_baseline.csv', fold_ct)

	print '''
\\begin{tabular}{lcc}
\\toprule
Scene & Baseline & Temporal scattering \\\\
\\midrule
'''[1:-1]

	labels = eval_scattering['labels']

	for i in range(len(labels)):
		row = ''

		row = row + labels[i]
		row = row + ' & '
		per_fold_accuracies = 100*eval_baseline['class_accuracies'][i]
		row = row + '${:04.1f} \pm {:04.1f}$'.format(per_fold_accuracies.mean(), per_fold_accuracies.std())
		row = row + ' & '
		per_fold_accuracies = 100*eval_scattering['class_accuracies'][i]
		row = row + '${:04.1f} \pm {:04.1f}$'.format(per_fold_accuracies.mean(), per_fold_accuracies.std())
		row = row + ' \\\\'
		row = row.replace(' 0', ' \\phantom{0}')
		row = row.replace('_', '\_')
		print row

	print '''
\\bottomrule
'''[1:-1]

	row = ''

	row = row + 'Average'
	row = row + ' & '
	per_fold_accuracies = 100*eval_baseline['mean_accuracies']
	row = row + '${:04.1f} \pm {:04.1f}$'.format(per_fold_accuracies.mean(), per_fold_accuracies.std())
	row = row + ' & '
	per_fold_accuracies = 100*eval_scattering['mean_accuracies']
	row = row + '${:04.1f} \pm {:04.1f}$'.format(per_fold_accuracies.mean(), per_fold_accuracies.std())
	row = row + ' \\\\'
	row = row.replace(' 0', ' \\phantom{0}')
	row = row.replace('_', '\_')
	print row

	print '''
\\end{tabular}
'''[1:-1]

def read_eval_csv(filename, fold_ct):
	csvfile = open(filename, 'r')
	csvreader = csv.reader(csvfile, delimiter=',', quotechar='"')

	eval_csv = {}

	i = 0
	eval_csv['labels'] = []
	eval_csv['class_accuracies'] = []

	for row in csvreader:
		eval_csv['labels'].append(row[0])

		eval_csv['class_accuracies'].append(np.zeros(fold_ct))
		for fold in range(fold_ct):
			eval_csv['class_accuracies'][i][fold] = float(row[1+fold])

		i = i+1

	eval_csv['mean_accuracies'] = np.mean(eval_csv['class_accuracies'], axis=0)

	csvfile.close()

	return eval_csv

main()
