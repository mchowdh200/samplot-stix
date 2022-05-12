
import os
from types import SimpleNamespace
configfile: 'conf/config.yaml'
config = SimpleNamespace(**config)


rule All:
    input:
        expand(f'{config.outdir}/{{specimen_type}}_symlinks',
               specimen_type=['tumor', 'normal'])
        # f'{config.outdir}/normal_symlinks', # directory
        # f'{config.outdir}/tumor_symlinks',  # directory
        # f'{config.outdir}/normals.ped',
        # f'{config.outdir}/tumors.ped',
        # f'{config.outdir}/normals.ped.db',
        # f'{config.outdir}/tumors.ped.db',

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

rule PartitionBeds:
    """
    Using the normal/tumor lists, create separate directories
    containing symlinks to the originals.
    """
    input:
        normal_beds = rules.GetTumorNormalBedLists.output.normal,
        tumor_beds = rules.GetTumorNormalBedLists.output.tumor
    output:
        normal = directory(f'{config.outdir}/normal_symlinks'),
        tumor = directory(f'{config.outdir}/tumor_symlinks')
    shell:
        f"""
        bash scripts/make_symlinks.sh {{input.normal_beds}} {config.beds} {{output.normal}}
        bash scripts/make_symlinks.sh {{input.tumor_beds}} {config.beds} {{output.tumor}}
        """

## Giggle Indices
# =============================================================================
rule MakeGiggleIndex:
    input:
        # rules.PartitionBeds.output.normal,
        f'{config.outdir}/{{specimen_type}}_symlinks'
    output:
        directory(f'{config.outdir}/{{specimen_type}}_giggle')
    threads:
        1
    shell:
        """
        bin/giggle index -i {input}/*.bed.gz -o {output} -s -f
        """

# rule MakeGiggleTumor:
#     input:
#         bed_list = rules.GetTumorNormalBedLists.output.tumor,
#     output:
#         directory(f'{config.outdir}/tumors')
#     threads:
#         1
#     shell:
#         f"""
#         bin/giggle index -i {config.beds}/$(<{{input.bed_list}}) \\
#             -o {{output}} -s -f
#         """

## Stix Indices
# ==============================================================================
# rule MakePedFiles:
#     input:
#        normal_list = rules.GetTumorNormalBedLists.output.normal,
#        tumor_list = rules.GetTumorNormalBedLists.output.tumor,
#        donor_table = config.donor_table
#     output:
#         normal = f'{config.outdir}/normals.ped',
#         tumor = f'{config.outdir}/tumors.ped'
#     conda:
#         'envs/pandas.yaml'
#     shell:
#         """
#         python scripts/make_ped_file.py \\
#             {input.normal_list} {input.donor_table} {output.normal}
#         python scripts/make_ped_file.py \\
#             {input.tumor_list} {input.donor_table} {output.tumor}
#         """
        
# rule MakeStixDBs:
#     input:
#         giggle_normal = rules.MakeGiggleNormal.output,
#         giggle_tumor = rules.MakeGiggleTumor.output,
#         normal = rules.MakePedFiles.output.normal,
#         tumor = rules.MakePedFiles.output.tumor,
#     output:
#         normal = f'{config.outdir}/normals.ped.db',
#         tumor = f'{config.outdir}/tumors.ped.db',
#     shell:
#         # -c is the column # of Alt_File
#         f"""
#         stix_bin=$(realpath bin/stix)
#         bash scripts/make_ped_db.sh {{input.giggle_normal}} {{input.normal}} {config.outdir} $stix_bin
#         bash scripts/make_ped_db.sh {{input.giggle_tumor}} {{input.tumor}} {config.outdir} $stix_bin
#         """

# rule MakeStixTumorDB:
