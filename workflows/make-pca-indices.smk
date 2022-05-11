
import os
from types import SimpleNamespace
configfile: 'conf/config.yaml'
config = SimpleNamespace(**config)


rule All:
    input:
        f'{config.outdir}/normals', # directory
        f'{config.outdir}/tumors',  # directory
        f'{config.outdir}/normal_list.txt',
        f'{config.outdir}/tumor_list.txt',

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
    shell:
        f"""
        bin/giggle index -i {config.beds}/$(<{{input.bed_list}}) \\
            -o {output} -s -f
        """

rule MakeGiggleTumor:
    input:
        bed_list = rules.GetTumorNormalBedLists.output.tumor,
    output:
        directory(f'{config.outdir}/tumors')
    shell:
        f"""
        bin/giggle index -i {config.beds}/$(<{{input.bed_list}}) \\
            -o {{output}} -s -f
        """

rule MakeStixNormalIndex:
rule MakeStixTumorIndex:
