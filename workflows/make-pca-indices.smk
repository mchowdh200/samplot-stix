
import os
from types import SimpleNamespace
## Setup
# =============================================================================
# TODO setup directory structure
#     - data DONE
#     - worklows DONE
#     - worklows/scripts DONE
#     - worklows/conf DONE
#     - worklows/bin (stix, gargs, etc) DONE
#     - worklows/envs (conda yamls) TODO

configfile: 'conf/config.yaml'
config = SimpleNamespace(**config)

## Rules
# =============================================================================

rule All:
    input:
        # f'{config.outdir}/done', # dummy output to check what files are actually output
        normal = f'{config.outdir}/normal_list.txt',
        tumor = f'{config.outdir}/tumor_list.txt',
        donor_list = os.path.abspath(config.donor_table),

rule GetTumorNormalBedLists:
    input:
        f'{config.beds}'
    output:
        normal = f'{config.outdir}/normal_list.txt',
        tumor = f'{config.outdir}/tumor_list.txt',
    shell:
        """
        bash scripts/get_tumor_file_ids.sh {input} {output.normal} {output.tumor}
        """

### TODO may need to split up to create the giggle index
### TODO can you create one big stix index and then
### just subset by sample?
rule MakeStixNormalIndex:
rule MakeStixTumorIndex:
