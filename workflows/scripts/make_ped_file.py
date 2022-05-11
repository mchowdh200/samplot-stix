import sys
import pandas as pd

bed_list = sys.argv[1]
donor_table = sys.argv[2]
output = sys.argv[3]

## Outline
# load donor table into dataframe
# get fid from bed list
# query dataframe with fid
# get relevant info
#     * ICGC Donor
#     * Specimen ID
#     * Specimen Type
#     * Sample ID (not the sample in bam unfortuneately)
#     * Project Study
#
# Format of Ped file will be
# Sample(FileID)  ICGC_Donor Specimen_ID  Specimen_Type Sample_ID  Project_Study  Alt_File(bed filename)

df = pd.read_csv(donor_table, sep='\t')
fids = [line.split('.')[0] for line in open(bed_list).readlines()]
df = df[df['File ID'].isin(fids)]

df.rename(inplace=True,
          columns={'File ID': 'Sample',
                   'ICGC Donor': 'ICGC_Donor',
                   'Specimen ID': 'Specimen_ID',
                   'Specimen Type': 'Specimen_Type',
                   'Sample ID': 'Sample_ID'},
          )
df['Alt_File'] = df.apply(lambda x: f'{x.Sample}.excord.bed.gz', axis=1)
df = df[['Sample', 'ICGC_Donor',
         'Specimen_Type', 'Specimen_ID',
         'Sample_ID', 'Project',
         'Study', 'Alt_File']] \
         .to_csv(output, sep='\t', index=False)
