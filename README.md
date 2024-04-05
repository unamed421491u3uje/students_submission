
# Learning from Students: Applying t-Distributions to Explore Accurate and Efficient Formats for LLMs

## Introduction
This codebase provides all the tools for replicating the results in the corresponding paper: **Learning from Students: Applying t-Distributions to Explore Accurate and Efficient Formats for LLMs**. It includes scripts for profiling LLM distributions, running LLMs for accuracy across datatypes, and generating the MAC hardware.


## Installation
First, install all the dependencies for the project. It is built from a modified version of Intel's neural compressor, where the majority of the unnecessary components are removed for simplicity. The requirements.txt is duplicated here, so all the dependencies can be installed with the following command:

```bash
pip install -r requirements.txt
```
Note that the `lm-evaluation-harness` must be pinned to the specific commit, as specificed in the requirement.txt, or there will be version mismatches.

## Accuracy
To evaluate model accuracy, use the provided run_llm.py script. This can perform evaluations across models, tasks, and datatypes. For example, the following command runs the OPT-125M model using default round-to-nearest (RTN) sub-channel quantization with the SF4 datatype, evaluated on LAMBADA.

```bash
python run_llm.py --model=facebook/opt-125m --quantize --batch_size=4 --tasks lambada_openai --woq_bits=4 --woq_dtype=sf4_5 --woq_group_size=128 --woq_algo=RTN
```

All the possible arguments are listed in the argparser in run_llm.py, but the most important arguments are highlighted below.

### Datatypes
 All datatypes are emulated using FP32 except for INT4, which uses native integer numerics, if the hardware supports it. The datatype is specified using the `woq_dtype` argument, and is applied when the `quantize` flag is included. The most important datatypes are listed below:

- **int4**: Standard integer quantization
- **nf4**: Normal Float format from QLoRA (Detmers et al.)
- **sf4_5**: Student float format introduced in this work. The degrees of freedom can be replaced with v in [3,7] inclusive, where the default value is 5.
- **fp4_e2m1**: Standard E2M1 format with subnormal support.
- **fp4_range**: Super-range variant of E2M1
- **fp4_prec2**: Super-precision variant of E2M1
- **apot4**: The 4-bit APoT datatype

All datatypes can be found with their defintions in neural_compressor/adaptor/torch_utils/weight_only.py.

### Algorithms
This file supports no quantization, weight-only quantization, and weight and activation quantization. It defaults to standard round-to-nearest (RTN) quantization, yet it also supports GPTQ, AWQ, and SmoothQuant. These methods can add additional accuracy in some situations. This can be specified with the `woq_algo` argument.

### Tasks
All tasks supported by the `lm_eval` library are supported during evaluation. These include LAMBADA (`lambada_openai`), WikiText2 (`wikitext`), PIQA (`piqa`), among many others.


## Model Profiling
The SF4 datatype was developed to match the LLM statistics for weights and activations. This profiling can be done with the `llm_profiling.ipynb` notebook.

## Datatype Analysis
For further analysis of the datatypes, use the `datatype_analysis.ipynb` found in `profiling/`. This file was used to generate many of the figures in the paper including the datatype comparison and Pareto curves. It calls `datatype_generators.py` for datatypes values, which parameterizes many of the datatypes for easy experimentation. 

## Hardware
The hardware models are located in the `/hardware` directory and include the files necessary to estimate the area and power using Synopsys
Design Compiler.