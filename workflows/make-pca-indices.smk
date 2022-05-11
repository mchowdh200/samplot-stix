
import os
from types import SimpleNamespace
## Setup
# =============================================================================
configfile: 'conf/config.yaml'
config = SimpleNamespace(**config)

## Rules
# =============================================================================

rule All:
    input:
        f'{config.outdir}/normal_giggle_done',
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

rule MakeGiggleNormal:
    input:
        bed_list = rules.GetTumorNormalBedLists.output.normal,
    output:
        # TODO for now I'm just going to touch an output file and see what the
        # outputs are, then modify this section
        f'{config.outdir}/normal_giggle_done'
    shell:
        f"""
        bin/giggle index -i bed/$(<{{input.bed_list}}) \\
            -o {config.outdir}/normals -s -f
        touch {{output}}
        """



rule MakeGiggleTumor:
rule MakeStixNormalIndex:
rule MakeStixTumorIndex:
