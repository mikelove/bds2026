library(tximeta)
stopifnot(packageVersion("tximeta") >= "1.31.3")

files <- "test/quants/ERR188021/quant.sf"
coldata <- data.frame(
  files = files,
  names = "ERR188021"
)

se <- importData(coldata, type="salmon", mixedDigest="mixed_ref_digests.json")

inspectDigests(se)
