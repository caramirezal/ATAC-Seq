## Snakemake pipeline for the processing of ATAC-Seq data

## python dependencies
import glob
import re
import os

## Setting config file
configfile: 'configs/config_miller.yml'

## Retrieving parameters from config file
datapath = config['datapath']

## Getting fastq files paths in recursively
fastq_paths = [ x for x in glob.glob(datapath + '/**/*.fastq.gz', 
				  recursive=True) ]

## Extract wildcards from list
ids = [re.sub(datapath, '', str) for str in fastq_paths]
ids = [re.sub('.*/|_1.fastq.gz|_2.fastq.gz', '', str) for str in ids]


## Running alignment
rule alignment:
    input:
        fastq_paths1=fastq_paths, 
        ids=ids
    #output:
    #    expand('output/bam/{id}.bam', id=ids)
    message: "Running alignment"
    run:
        for i in range(len(fastq_paths)):
            command = ''.join(('bowtie2 ',  
			        ' -x ', config['index'],
                                ' -1 ', input.fastq_paths1[i], '_1.fastq.gz',
                                ' -2 ', input.fastq_paths2[i], '_2.fastq.gz',
                                ' --very-sensitive -q -p 6 ',
                                ' 2> ', 'log/', input.ids[i], '.log',
                                ' | samtools view -h -bS - > ', 
                                output[i]))
            print('Executing: ' + command)
            #shell(command)
            #shell('touch ' + output[i])


