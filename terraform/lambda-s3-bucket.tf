resource "aws_s3_bucket_object" "object_jar" {
  bucket = "${var.bucket_name}"
  key    = "${var.git_marker}/lambda-chaining-1.0-SNAPSHOT.jar"
  source = "lambda-chaining-1.0-SNAPSHOT.jar"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = "${filemd5("lambda-chaining-1.0-SNAPSHOT.jar")}"
}
