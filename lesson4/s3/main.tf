resource "random_string" "for_bucket" {
    count  = var.bucket_count

    length = 4
    special = false
 
    upper = false
}


resource "aws_s3_bucket" "bucket" {
    count = var.bucket_count > 1 ? var.bucket_count : 1
    bucket = "my-bucket-roza${random_string.for_bucket[count.index].id}"
    versioning {
    enabled = var.versioning_enabled
    }

  }
