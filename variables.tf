variable "env" {
  description = "local,dev,prod environment setting"
}

variable "region" {
  description = "AWS region"
  default     = "ap-northeast-2"
}

variable "amazon_linux_2023_id" {
  description = "아마존 linux 2023 이미지 ID"
  default = "ami-00d253f3826c44195"
}