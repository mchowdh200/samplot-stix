
import os
from types import SimpleNamespace
configfile: 'conf/config.yaml'
config = SimpleNamespace(**config)


rule All:
    input:
        f'{config.outdir}/normals', # directory
        f'{config.outdir}/tumors',  # directory
        f'{config.outdir}/normals.ped',
        f'{config.outdir}/tumors.ped',
        f'{config.outdir}/normals.ped.db',
        f'{config.outdir}/tumors.ped.db',

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
        normal = f'{config.outdir}/normals.ped',
        tumor = f'{config.outdir}/tumors.ped'
    conda:
        'envs/pandas.yaml'
    shell:
        """
        python scripts/make_ped_file.py \\
            {input.normal_list} {input.donor_table} {output.normal}
        python scripts/make_ped_file.py \\
            {input.tumor_list} {input.donor_table} {output.tumor}
        """
        
rule MakeStixDBs:
    input:
        normal = rules.MakePedFiles.output.normal,
        tumor = rules.MakePedFiles.output.tumor,
    output:
        normal = f'{config.outdir}/normals.ped.db',
        tumor = f'{config.outdir}/tumors.ped.db',
    shell:
        # -c is the column # of Alt_File
        f"""
        stix_bin=$(realpath bin/stix)
        bash scripts/make_ped_db.sh {config.beds} {{input.normal}} {config.outdir} $stix_bin
        bash scripts/make_ped_db.sh {config.beds} {{input.tumor}} {config.outdir} $stix_bin
        """

rule MakeStixTumorDB:
