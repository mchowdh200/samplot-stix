
import os
from types import SimpleNamespace
configfile: 'conf/config.yaml'
config = SimpleNamespace(**config)


rule All:
    input:
        f'{config.outdir}/normals', # directory
        f'{config.outdir}/tumors',  # directory
        f'{conf.outdir}/normals.ped',
        f'{conf.outdir}/tumors.ped'

rule GetTumorNormalBedLists:
    input:
        beds = os.path.abspath(config.beds),
        donor_list = os.path.abspath(config.donor_table),
        
    output:
        normal = f'{config.outdir}/normal_list.txt',
        tumor = f'{config.outdir}/tumor_list.txt',
    shell:
        """
        bash scripts/get_tumor_file_ids.sh {input.beds} {input.donor_list} {output.normal} {output.tumor}
        """

## Giggle Indices
# =============================================================================
rule MakeGiggleNormal:
    input:
        bed_list = rules.GetTumorNormalBedLists.output.normal,
    output:
        directory(f'{config.outdir}/normals')
    threads:
        1
    shell:
        f"""
        bin/giggle index -i {config.beds}/$(<{{input.bed_list}}) \\
            -o {{output}} -s -f
        """

rule MakeGiggleTumor:
    input:
        bed_list = rules.GetTumorNormalBedLists.output.tumor,
    output:
        directory(f'{config.outdir}/tumors')
    threads:
        1
    shell:
        f"""
        bin/giggle index -i {config.beds}/$(<{{input.bed_list}}) \\
            -o {{output}} -s -f
        """

## Stix Indices
# ==============================================================================
rule MakePedFiles:
    input:
       normal_list = rules.GetTumorNormalBedLists.output.normal,
       tumor_list = rules.GetTumorNormalBedLists.output.tumor,
       donor_table = config.donor_table
    output:
        normal = f'{conf.outdir}/normals.ped',
        tumor = f'{conf.outdir}/tumors.ped'
    conda:
        'envs/pandas.yaml'
    shell:
        """
        python make_ped_file.py \\
            {input.normal_list} {input.donor_table} {output.normal}
        python make_ped_file.py \\
            {input.tumor_list} {input.donor_table} {output.tumor}
        """
        
rule MakeStixNormalIndex:
rule MakeStixTumorIndex:
