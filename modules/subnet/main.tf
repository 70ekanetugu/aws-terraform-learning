resource "aws_subnet" "default" {
  count = length(var.availability_zones) # 指定AZ分サブネットを作成

  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.${(var.is_public ? 0 : 64) + count.index}.0/24"
  map_public_ip_on_launch = var.is_public
  availability_zone       = var.availability_zones[count.index]

  tags = {
    # 指定されたタグ名 + suffixにAZ
    Name = "${var.tag_name}-${substr(var.availability_zones[count.index], (length(var.availability_zones[count.index]) - 2), (length(var.availability_zones[count.index]) - 1))}"
  }
}
