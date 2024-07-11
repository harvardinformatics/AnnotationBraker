localrules: braker_mover

rule braker3_bams:
    input:
        proteindb=config["orthodb"],
        bams=expand("{directory}{bam}",directory=config["bamdir"],bam=BAMS),
        genome=config["genome"]
    params:
        brakersif=config["brakersif"],
        species=config["species"],
        bamstring=",".join(expand("{directory}{bam}",directory=config["bamdir"],bam=BAMS))
    output:
        "braker/braker.gtf"
    threads: 48
    shell:
       """
       singularity exec --cleanenv {params.brakersif} cp -Rs /opt/Augustus/config/ augustus_config
       singularity exec --no-home \
                 --home /opt/gm_key \
                 --cleanenv \
                 --env AUGUSTUS_CONFIG_PATH=${{PWD}}/augustus_config \
                 {params.brakersif} braker.pl \
                 --prot_seq={input.proteindb} \
                 --bam={params.bamstring} \
                 --species={params.species}_eval \
                 --genome={input.genome} \
                 --threads={threads}
       """       

rule braker_mover:
    input:
        "braker/braker.gtf"
    output:
        "results/braker3/braker/braker.gtf"
    threads: 1
    shell:
        """
        mkdir -p results/braker3
        mv augustus_config results/braker3
        mv braker results/braker3
        """
