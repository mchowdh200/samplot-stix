
import os
from types import SimpleNamespace
configfile: 'conf/config.yaml'
config = SimpleNamespace(**config)


rule All:
    input:
        expand(f'{config.outdir}/{{specimen_type}}.ped.db',
               specimen_type=['tumor', 'normal']),
        expand(f'{config.outdir}/{{specimen_type}}.ped',
               specimen_type=['tumor', 'normal']),
        expand(f'{config.outdir}/{{specimen_type}}.ped',
               specimen_type=['tumor', 'normal']),
        # expand(f'{config.outdir}/{{specimen_type}}_giggle',
        #        specimen_type=['tumor', 'normal'])

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
        f'{config.outdir}/{{specimen_type}}_symlinks'
    output:
        directory(f'{config.outdir}/{{specimen_type}}_giggle')
    threads:
        1
    shell:
        """
        bin/giggle index -i "{input}/*.gz" -o {output} -s
        """


## Stix Indices
# ==============================================================================
rule MakePedFile:
    input:
       list = f'{config.outdir}/{{specimen_type}}_list.txt',
       donor_table = config.donor_table
    output:
        f'{config.outdir}/{{specimen_type}}.ped',
    conda:
        'envs/pandas.yaml'
    shell:
        """
        python scripts/make_ped_file.py \\
            {input.list} {input.donor_table} {output}
        """
        
rule MakeStixDBs:
    input:
        giggle_index = rules.MakeGiggleIndex.output,
        ped = rules.MakePedFile.output,
    output:
        f'{config.outdir}/{{specimen_type}}.ped.db',
    shell:
        f"""
        bin/stix -i {{input.giggle_index}} -p {{input.ped}} -d {{output}} -c 8 #col of alt_file
        """

