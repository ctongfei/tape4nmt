import "tapes/packages.tape"
import "tapes/submitters.tape"
import "tapes/versioners.tape"
import "tapes/dummy.tape"

# ==== pipeline starts here ====

# download all the data to the local directory
import "tapes/download.tape"

# prepare downloaded training data:
# - clean: remove empty lines, remove sentence pairs with large length ratio
# - sample: sample a certain number of lines of data
import "tapes/prepare_train.tape"

# prepare dev/test data, e.g. extract text from sgm:
# - extract dev/test from sgm format, if the wrapping exists
import "tapes/prepare_devtest.tape"

# merge multiple train/dev/test sets
# note that merging of train/dev is mandatory,
# while test is controlled by the branch point `MergeTest`
import "tapes/merge.tape"

# tasks related to tokenize
import "tapes/tokenize.tape"

# tasks related to truecase
import "tapes/truecase.tape"

# tasks related to bpe
import "tapes/bpe.tape"

# task binarize_data, train and decode fits in here in the execution order
# these tasks are usually the ones that needs to be defined for each toolkit
import "tapes/fairseq.tape"
# import "tapes/onmt.tape"
# import "tapes/sockeye.tape"

# the order here is the reverse of the preprocessing
# usually: debpe -> detruecase -> detokenize
# if you need nist-bleu, you'll have to wrap up output into xml as well
import "tapes/postprocessing.tape"

# currently support nist_bleu and multi_bleu
# sacrebleu to be supported
import "tapes/bleu.tape"

# ==== pipeline ends here ====

plan test {
  reach multi_bleu via (SgmDev: yes) * (SgmTest: yes) * (MergeTest: yes) * (UseExistingTruecaser: no) * (TrainSampleSize: DontSample) * (DoTokenize: yes) * (DoTruecase: yes) * (DoBPE: yes) * (TrainDataSource: iwslt_deen_2014) * (DevDataSource: iwslt_deen_dev2010 iwslt_deen_dev2012) * (TestDataSource: iwslt_deen_test2010 iwslt_deen_test2011 iwslt_deen_test2012) * (Architecture: fconv_iwslt_de_en) * (ClipNorm: 0.1) * (Dropout: 0.1) * (BpeMergeOps: 49500)
}

# Nuts and bolts:
global {
  ducttape_experimental_packages=true
  ducttape_experimental_submitters=true
  ducttape_experimental_imports=true
  ducttape_experimental_multiproc=true
}

