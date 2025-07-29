resource "aws_s3_bucket" "bucket_rag_customerlist" {
  bucket = "${var.unique_identifier}-togglebank-rag-customerlist"
}

resource "aws_s3_bucket" "bucket_rag_faq" {
  bucket = "${var.unique_identifier}-togglebank-rag-faq"
}
